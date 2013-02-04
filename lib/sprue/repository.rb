require 'json'

class Sprue::Repository
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  ACTIVE_VARIANT = '!'.freeze
  QUEUE_VARIANT = '*'.freeze
  ENTITY_KEY_SEPARATOR = '#'.freeze
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
    key =
      case (entity)
      when Sprue::Entity
        [ entity.class.to_s, entity.ident ].join(ENTITY_KEY_SEPARATOR)
      else
        entity = entity.to_s

        if (entity.match(ENTITY_KEY_SEPARATOR))
          entity
        else
          [ entity_class, entity ].join(ENTITY_KEY_SEPARATOR)
        end
      end

    variant ? (key + variant.to_s) : key
  end

  def pop!(queue = nil, queue_class = nil, block = true)
    ident =
      if (block)
        @connection.blpop(entity_key(queue, queue_class), 0)
      else
        @connection.lpop(entity_key(queue, queue_class))
      end

    ident and self.load!(ident)
  end

  def push!(entity, entity_class = nil, queue = nil, queue_class = Sprue::Queue)
    @connection.rpush(
      entity_key(queue, queue_class, QUEUE_VARIANT),
      entity_key(entity, entity_class)
    )
  end

  def queue_length(queue = nil, queue_class = Sprue::Queue)
    key = entity_key(queue, queue_class, QUEUE_VARIANT)

    @connection.exists(key) and @connection.llen(key) or nil
  end

  def load!(ident, entity_class = nil)
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

  def inactive!(entity, entity_class = nil, timeout = nil)
    key = entity_key(entity, entity_class, ACTIVE_VARIANT)
    
    @connection.del(key)
  end

  def active?(entity, entity_class = nil)
    key = entity_key(entity, entity_class, ACTIVE_VARIANT)

    @connection.exists(key)
  end
end
