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

  def queue_pop!(queue, agent = nil, timeout = nil)
    queue_key = subkey(queue, QUEUE_ENTRIES_SUBKEY)

    popped =
      if (agent)
        agent_key = subkey(agent, QUEUE_ENTRIES_SUBKEY)

        if (timeout)
          @connection.brpoplpush(queue_key, agent_key, timeout)
        else
          @connection.rpoplpush(queue_key, agent_key)
        end
      else
        if (timeout)
          @connection.brpop(queue_key, timeout)
        else
          @connection.rpop(queue_key)
        end
      end

    return unless (popped)

    materialize(popped)
  end

  def queue_push!(queue, entity)
    queue_key = subkey(queue, QUEUE_ENTRIES_SUBKEY)

    case (entity)
    when Array, Hash
      @connection.lpush(queue_key, JSON.dump(entity))
    else
      @connection.lpush(queue_key, entity.to_s)
    end
  end

  def queue_shift!(queue, discard = false)
    queue_key = subkey(queue, QUEUE_ENTRIES_SUBKEY)

    if (discard)
      @connection.lpop(queue_key)

      return
    end

    shifted = @connection.lpop(queue_key)

    return unless (shifted)

    materialize(shifted)
  end

  def queue_pull!(queue, entity)
    queue_key = subkey(queue, QUEUE_ENTRIES_SUBKEY)

    @connection.lrem(queue_key, 0, entity.to_s)
  end

  def queue_drop!(queue)
    queue_key = subkey(queue, QUEUE_ENTRIES_SUBKEY)
    
    @connection.del(queue_key)
  end

  def queue_length(queue)
    queue_key = subkey(queue, QUEUE_ENTRIES_SUBKEY)

    @connection.exists(queue_key) and @connection.llen(queue_key) or 0
  end

  def entity_load!(key)
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

  def entity_save!(entity)
    key, values = Sprue::Serializer.serialize(
      entity.to_s,
      entity.attributes,
      entity.class.attributes
    )

    @connection.hmset(key, values)
  end

  def entity_delete!(entity)
    @connection.del(entity.to_s)
    @connection.del(subkey(entity, ACTIVE_SUBKEY))
  end

  def entity_exist?(entity)
    @connection.exists(entity.to_s)
  end

  def entity_active!(entity, agent = nil, timeout = nil)
    key = subkey(entity, ACTIVE_SUBKEY)

    agent ||= "%s:%d" % [ Socket.gethostname, $$ ]
    
    @connection.set(key, agent.to_s)
    @connection.expire(key, timeout || DEFAULT_TIMEOUT)
  end

  def entity_inactive!(entity)
    key = subkey(entity, ACTIVE_SUBKEY)
    
    @connection.del(key)
  end

  def entity_active?(entity)
    key = subkey(entity, ACTIVE_SUBKEY)

    @connection.exists(key)
  end

  def tag_subscribe!(tag, queue)
    @connection.sadd(tag.to_s, queue.to_s)
  end

  def tag_subscriber?(tag, queue)
    @connection.sismember(tag.to_s, queue.to_s)
  end

  def tag_subscribers(tag)
    @connection.smembers(tag.to_s)
  end

  def tag_subscribers_count
    @connection.scard(tag.to_s)
  end

  def tag_unsubscribe!(tag, queue)
    @connection.srem(tag.to_s, queue.to_s)
  end

  def tag_delete!(tag)
    @connection.del(tag.to_s)
  end

protected
  def materialize(object)
    case (object[0,1])
    when '{', '['
      JSON.load(object)
    else
      self.entity_load!(object)
    end
  end
end
