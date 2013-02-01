require 'json'

class Sprue::Serializer
  # == Subclasses ===========================================================
  
  autoload(:Agent, 'sprue/serializer/agent')
  autoload(:Job, 'sprue/serializer/job')

  # == Extensions ===========================================================
  
  # == Constants ============================================================

  ENCODING_METHODS = {
    :string => {
      :serialize => lambda { |v| v.to_s },
      :deserialize => lambda { |v| v }
    },
    :integer => {
      :serialize => lambda { |v| v.to_s },
      :deserialize => lambda { |v| v.to_i }
    },
    :time => {
      :serialize => lambda { |v| v.to_i.to_s },
      :deserialize => lambda { |v| Time.at(v.to_i).utc }
    },
    :csv => {
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

  # == Class Methods ========================================================

  def self.attributes
    @attributes ||= { }
  end

  def self.attribute(name, options = nil)
    # FUTURE: Warn on invalid encoding methods?
    as = options && options[:as] || DEFAULT_ENCODING
    defaults = ENCODING_METHODS[as] || ENCODING_METHODS[DEFAULT_ENCODING]

    self.attributes[name] = defaults.merge(options || { })
  end

  def self.hash_to_list(hash)
    hash.to_a.flatten.collect(&:to_s)
  end

  def self.list_to_hash(list)
    hash = { }

    list.each_with_index do |k, i|
      next if (i % 2 == 1)

      hash[k] = list[i + 1]
    end

    hash
  end

  def self.singleton
    @singleton ||= self.new
  end

  def self.serialize(attributes)
    self.singleton.serialize(attributes)
  end

  def self.deserialize(ident, values)
    self.singleton.deserialize(ident, values)
  end
  
  # == Instance Methods =====================================================

  def serialize(attributes)
    ident = attributes[:ident]
    values = [ ]

    self.class.attributes.each do |name, options|
      next if (name == :ident)

      value = attributes[name]

      values << name.to_s

      values <<
        if (!value.nil? or options[:allow_nil])
          options[:serialize].call(attributes[name])
        else
           ''
        end
    end

    [ ident, values ]
  end

  def deserialize(ident, values)
    attributes = {
      :ident => ident
    }

    case (values)
    when Array
      values = self.class.list_to_hash(values)
    end

    self.class.attributes.each do |name, options|
      value = values[name.to_s]

      attributes[name] =
        if (value == '' and !options[:allow_blank])
          nil
        else
          options[:deserialize].call(value)
        end
    end

    attributes
  end
end
