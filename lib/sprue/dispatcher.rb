class Sprue::Dispatcher < Sprue::Agent
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  COMMANDS = [
    SUBSCRIBE_COMMAND = 'subscribe'.freeze,
    UNSUBSCRIBE_COMMAND = 'unsubscribe'.freeze
  ].freeze

  AGENT_IDENT = 'agent_ident'.freeze
  REINJECT = 'reinject'.freeze

  REJECT_POSTFIX = '/r'.freeze
  
  # == Properties ===========================================================

  attr_reader :context
  attr_reader :ident
  attr_reader :inbound_queue
  attr_reader :claimed_queue
  attr_reader :rejected_queue

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(context, options = nil)
    super(context, options)

    @rejected_queue = @context.queue(@ident + REJECT_POSTFIX)

    @tag_subscribers = Hash.new { |h,k| h[k] = [ ] }
  end

  def tag_subscribers(tag)
    return [ ] unless (@tag_subscribers.key?(tag))

    @tag_subscribers[tag].collect { |e| e[0] }
  end

  def backlog?
    @inbound_queue.length > 0
  end

  def backlog_count
    @inbound_queue.length
  end

  def claimed?
    @claimed_queue.length > 0
  end

  def claimed_count
    @claimed_queue.length
  end

protected
  def tags_for_entity(entity)
    entity.respond_to?(:tags) ? entity.tags : [ ]
  end

  def handle_job(job)
    true
  end

  def handle_entity(entity)
    tags = tags_for_entity(entity)

    tags.each do |tag|
      set = @tag_subscribers[tag]

      next if (set.empty?)

      agent_entry = set.shift

      if (agent_entry[1])
        set.push(agent_entry)
      end

      @inbound_queue.shift!(true)
      @repository.queue_push!(agent_entry[0], entity)

      return true
    end

    return
  end

  def handle_command(command)
    agent_ident = command[AGENT_IDENT]

    if (tag = command[SUBSCRIBE_COMMAND])
      @tag_subscribers[tag] << [ agent_ident, !!command[REINJECT] ]
    elsif (tag = command[UNSUBSCRIBE_COMMAND])
      set = @tag_subscribers[tag]

      set.delete(agent_ident)

      if (set.empty?)
        @tag_subscribers.delete(tag)
      end
    elsif (tag = command[ECHO_COMMAND])
      @repository.queue_push!(agent_ident, command)
    else
      # NOTE: Sending a response to the client might help.
      @rejected_queue.push!(command)
    end

    true
  end
end
