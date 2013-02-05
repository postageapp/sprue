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

  attr_reader :ident
  attr_reader :repository

  # == Class Methods ========================================================

  def self.attributes
    @attributes ||= DEFAULT_ATTRIBUTES.dup
  end

  def self.attribute(name, options = nil)
    # FUTURE: Warn on invalid encoding methods?
    as = options && options[:as] || DEFAULT_ENCODING
    defaults = ENCODING_METHODS[as] || ENCODING_METHODS[DEFAULT_ENCODING]

    instance_variable = :"@#{name}"

    options = self.attributes[name] = defaults.merge(
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

  def self.repository_key_split(ident)
    entity_class, ident = ident.split(KEY_SEPARATOR)

    # This reduce method functions as the equivalent of String#constantize

    # FIX: Test that entity_class is Entity-derived?
    # FIX: Trap on invalid classes when using reduce (inject?)

    [ ident, entity_class.split('::').reduce(Module, :const_get) ]
  end

  def self.repository_key(ident)
    [ self, ident ].join(KEY_SEPARATOR)
  end

  def self.instantiate(ident, attributes)
    entity_class, ident = repository_key_split(ident)

    entity_class.new(attributes)
  end

  # == Instance Methods =====================================================

  def initialize(with_attributes = nil, repository = nil)
    self.class.attributes.each do |name, options|
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

  def repository_key
    [ self.class, @ident ].join(KEY_SEPARATOR)
  end
  alias_method :to_s, :repository_key

  def ident
    @ident
  end

  def ident=(value)
    @ident = value ? value.to_s : nil
  end

  def serialize(attributes)
    Sprue::Serializer.serialize(attributes, self.class.attributes)
  end

  def deserialize(ident, values)
    Sprue::Serializer.deserialize(ident, values, self.class.attributes)
  end

  def attributes
    Hash[
      self.class.attributes.collect do |name, options|
        [ name, instance_variable_get(options[:instance_variable]) ]
      end
    ]
  end

  def save!(repository = nil)
    unless (@repository)
      @repository ||= repository
    end
    
    repository ||= @repository

    return false unless (repository)

    repository.save!(self)
  end

  def delete!(repository = nil)
    repository ||= @repository

    return false unless (repository)

    repository.delete!(self)
  end
end
