class Sprue::Entity
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  KEY_SEPARATOR = '#'.freeze

  DEFAULT_ATTRIBUTES = {
    :ident => {
      :default => lambda { Sprue::Context.generate_ident },
      :cast => lambda { |v| v.nil? ? nil : v.to_s },
      :serialize => lambda { |v| v.to_s },
      :deserialize => lambda { |v| v },
      :instance_variable => :@ident
    }
  }.freeze

  ENCODING_METHODS = {
    :string => {
      :cast => lambda { |v| v.nil? ? nil : v.to_s },
      :serialize => lambda { |v| v.to_s },
      :deserialize => lambda { |v| v }
    },
    :integer => {
      :cast => lambda { |v| v.nil? ? nil : v.to_i },
      :serialize => lambda { |v| v.to_s },
      :deserialize => lambda { |v| v.to_i }
    },
    :time => {
      :serialize => lambda { |v| v.to_i.to_s },
      :deserialize => lambda { |v| Time.at(v.to_i).utc }
    },
    :csv => {
      :cast => lambda { |v| v.nil? ? [ ] : [ v ].flatten.to_a },
      :default => lambda { [ ] },
      :serialize => lambda { |v| v.join(',') },
      :deserialize => lambda { |v| v.split(',') },
      :allow_blank => true
    },
    :json => {
      :serialize => lambda { |v| JSON.dump(v) },
      :deserialize => lambda { |v| JSON.load(v) }
    }
  }.freeze

  DEFAULT_ENCODING = :string

  # == Properties ===========================================================

  attr_reader :repository

  # == Class Methods ========================================================

  # Returns the attributes defined for this class of Entity as a Hash where
  # the key is the name of the attribute and the value is the configured
  # options for that attribute.
  def self.attribute_options
    @attribute_options ||= DEFAULT_ATTRIBUTES.dup
  end

  # Used to define an attribute for a particular class of Entity with a given
  # name and optional arguments:
  #  * :as - Uses a pre-defined encoding method for serialization and casting.
  #  * :cast - Defines how to cast values supplied to the attr_writer method
  #    before storing them by supplying a block that takes one argument.
  #  * :instance_variable - Defines the name of the instance variable used to
  #    store the value of this attribute.
  def self.attribute(name, options = nil)
    # FUTURE: Warn on invalid encoding methods?
    as = options && options[:as] || DEFAULT_ENCODING
    defaults = ENCODING_METHODS[as] || ENCODING_METHODS[DEFAULT_ENCODING]

    instance_variable = :"@#{name}"

    options = self.attribute_options[name] = defaults.merge(
      :instance_variable => instance_variable
    ).merge(options || { })

    define_method(name) do
      instance_variable_get(instance_variable)
    end

    if (cast = options[:cast])
      define_method(:"#{name}=") do |value|
        instance_variable_set(instance_variable, cast.call(value))
      end
    else
      define_method(:"#{name}=") do |value|
        instance_variable_set(instance_variable, value)
      end
    end
  end

  # Splits apart a supplied key and returns the Entity class and ident as two
  # separate values. This requires the class to be defined or loadable or an
  # exception may occur and expects that the key has been produced by the
  # repository_key method or something equivalent.
  def self.repository_key_split(key)
    entity_class, ident = key.split(KEY_SEPARATOR)

    # This reduce method functions as the equivalent of String#constantize

    # FIX: Test that entity_class is Entity-derived?
    # FIX: Trap on invalid classes when using reduce (inject?)

    [ entity_class.split('::').reduce(Module, :const_get), ident ]
  end

  # Combines the given ident with this class name and returns the repository
  # key as a string. These elements are joined with the default key separator.
  def self.repository_key(ident)
    [ self, ident ].join(KEY_SEPARATOR)
  end

  # Creates an Entity of the appropriate class based on the supplied ident
  # and de-serialized attributes.
  def self.instantiate(ident, attributes)
    entity_class, ident = repository_key_split(ident)

    entity_class.new(attributes)
  end

  # == Instance Methods =====================================================

  # Creates a new entity with the specified attributes, if any, and an optional
  # repository. The repsository can be assigned later during a call to `save!`
  def initialize(with_attributes = nil, repository = nil)
    self.class.attribute_options.each do |name, options|
      value = with_attributes && with_attributes[name]

      if (value.nil?)
        default = options[:default]
        
        if (default.respond_to?(:call))
          value = default.call
        else
          value = default
        end
      end

      if (cast = options[:cast])
        value = cast.call(value)
      end

      instance_variable_set(options[:instance_variable], value)
    end

    @repository = repository
  end

  # Returns the key used to store this Entity in the repository by combining
  # the Entity class name with the ident using the default key separator.
  def repository_key
    [ self.class, @ident ].join(KEY_SEPARATOR)
  end
  alias_method :to_s, :repository_key

  # Returns the ident of this Entity.
  def ident
    @ident
  end

  # Assigns the ident of this Entity. Requires a save call before the Entity
  # is commited under this ident. Will not delete the data associated with
  # any previous idents. Any supplied value should be either a String or an
  # object with a valid `to_s` method.
  def ident=(value)
    @ident = value ? value.to_s : nil
  end

  # Serializes the Entity into an array.
  def serialize(attributes)
    Sprue::Serializer.serialize(attributes, self.class.attribute_options)
  end

  # Deserializes the Entity from the provided ident and values array.
  def deserialize(ident, values)
    Sprue::Serializer.deserialize(ident, values, self.class.attribute_options)
  end

  # Returns the attributes of this Entity as a Hash where the key is the name
  # and the value is the stored value.
  def attributes
    Hash[
      self.class.attribute_options.collect do |name, options|
        [ name, instance_variable_get(options[:instance_variable]) ]
      end
    ]
  end

  # Saves an entity to the specified repository, or if no repository is
  # specified, from the repository previously used to load or save the Entity.
  # Triggers before_save and after_save methods.
  def save!(repository = nil)
    unless (@repository)
      @repository ||= repository
    end
    
    repository ||= @repository

    self.before_save

    repository.entity_save!(self)

    self.after_save

    return
  end

  # Returns true if the Entity has been saved, false otherwise.
  def saved?
    @repository.exist?(self)
  end

  # Deletes an entity from the specified repository, or if no repository is
  # specified, from the repository previously used to load or save the Entity.
  # Triggers before_delete and after_delete methods.
  def delete!(repository = nil)
    repository ||= @repository

    self.before_delete

    repository.entity_delete!(self)

    self.after_delete

    return
  end

  def deleted?
    !@repository.exist?(self)
  end

protected
  # Re-define before_save in a subclass to perform actions before the Entity
  # will be saved.
  def before_save
    # Customized in subclasses
  end

  # Re-define after_save in a subclass to perform actions after the Entity
  # was saved.
  def after_save
    # Customized in subclasses
  end

  # Re-define before_delete in a subclass to perform actions before the Entity
  # will be deleted.
  def before_delete
    # Customized in subclasses
  end

  # Re-define after_delete in a subclass to perform actions after the Entity
  # was deleted.
  def after_delete
    # Customized in subclasses
  end
end
