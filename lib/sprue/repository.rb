class Sprue::Repository
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  ACTIVE_SUBKEY = '!'.freeze
  QUEUE_ENTRIES_SUBKEY = '*'.freeze
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

  def subkey(key, subkey)
    key.to_s + subkey
  end

  def pop!(queue, agent = nil, block = false)
    key = subkey(queue, QUEUE_ENTRIES_SUBKEY)

    popped_key =
      if (block)
        @connection.blpop(key, 0)
      else
        @connection.lpop(key)
      end

    popped_key and self.load!(popped_key)
  end

  def push!(queue, entity)
    @connection.rpush(
      subkey(queue, QUEUE_ENTRIES_SUBKEY),
      entity.to_s
    )
  end

  def length(queue)
    key = subkey(queue, QUEUE_ENTRIES_SUBKEY)

    @connection.exists(key) and @connection.llen(key) or 0
  end

  def load!(key)
    values = @connection.hgetall(key.to_s)

    if (values.empty?)
      return
    end

    ident, entity_class = Sprue::Entity.repository_key_split(key)

    attributes = Sprue::Serializer.deserialize(
      ident,
      values,
      entity_class.attributes
    )

    entity_class.new(attributes, self)
  end

  def save!(entity)
    key, values = Sprue::Serializer.serialize(
      entity.to_s,
      entity.attributes,
      entity.class.attributes
    )

    @connection.hmset(key, values)
  end

  def delete!(entity)
    @connection.del(entity.to_s)
    @connection.del(subkey(entity, ACTIVE_SUBKEY))
  end

  def exist?(entity)
    @connection.exists(entity.to_s)
  end

  def active!(entity, timeout = nil)
    key = subkey(entity, ACTIVE_SUBKEY)
    
    @connection.set(key, "%s:%d" % [ Socket.gethostname, $$ ])
    @connection.expire(key, timeout || DEFAULT_TIMEOUT)
  end

  def inactive!(entity)
    key = subkey(entity, ACTIVE_SUBKEY)
    
    @connection.del(key)
  end

  def active?(entity)
    key = subkey(entity, ACTIVE_SUBKEY)

    @connection.exists(key)
  end
end
