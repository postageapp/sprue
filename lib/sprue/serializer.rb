require 'json'

module Sprue::Serializer
  # == Module Methods =======================================================

  def hash_to_list(hash)
    hash.to_a.flatten.collect(&:to_s)
  end

  def list_to_hash(list)
    hash = { }

    list.each_with_index do |k, i|
      next if (i % 2 == 1)

      hash[k] = list[i + 1]
    end

    hash
  end

  def serialize(ident, attributes, attribute_options)
    values = [ ]

    attribute_options.each do |name, options|
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

  def deserialize(ident, values, attribute_options)
    attributes = {
      :ident => ident.respond_to?(:ident) ? ident.ident : ident
    }

    case (values)
    when Array
      values = list_to_hash(values)
    end

    attribute_options.each do |name, options|
      next if (name == :ident)

      value = values[name.to_s]

      attributes[name] =
        if (value == '' and !options[:allow_blank])
          nil
        elsif (!value.nil? or (value.nil? and options[:allow_nil]))
          options[:deserialize].call(value)
        else
          nil
        end
    end

    attributes
  end

  extend self
end
