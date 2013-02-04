require 'json'

class Sprue::Repository
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  ACTIVE_VARIANT = '!'.freeze
  DEFAULT_TIMEOUT = 30
  
  # == Properties ===========================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize(connection)
    @connection = connection
  end

  def context
    @connection.context
  end

  def entity_key(entity, entity_class = nil, variant = nil)
    key = [
      (entity_class || entity).ident_prefix,
      entity.respond_to?(:ident) ? entity.ident : entity
    ].join(':')

    if (variant)
      key << variant.to_s
    end

    key
  end

  def load!(ident, entity_class)
    values = @connection.hgetall(entity_key(ident, entity_class))

    if (values.empty?)
      return
    end

    attributes = Sprue::Serializer.deserialize(
      ident,
      values,
      entity_class.attributes
    )

    entity_class.new(attributes, self)
  end

  def save!(entity)
    key, values = Sprue::Serializer.serialize(
      entity_key(entity),
      entity.attributes,
      entity.class.attributes
    )

    @connection.hmset(key, values)
  end

  def delete!(entity, entity_class = nil)
    key = entity_key(entity, entity_class)

    @connection.del(key)

    key = entity_key(entity, entity_class, ACTIVE_VARIANT)

    @connection.del(key)
  end

  def exist?(entity, entity_class = nil)
    @connection.exists(entity_key(entity, entity_class))
  end

  def active!(entity, entity_class = nil, timeout = nil)
    key = entity_key(entity, entity_class, ACTIVE_VARIANT)
    
    @connection.set(key, "%s:%d" % [ Socket.gethostname, $$ ])
    @connection.expire(key, timeout || DEFAULT_TIMEOUT)
  end

  def active?(entity, entity_class = nil)
    key = entity_key(entity, entity_class, ACTIVE_VARIANT)

    @connection.exists(key)
  end
end
