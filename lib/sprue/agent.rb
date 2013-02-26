class Sprue::Agent
  # == Extensions ===========================================================

  # == Constants ============================================================

  CLAIMED_POSTFIX = '/c'.freeze

  # == Properties ===========================================================

  attr_reader :context
  attr_reader :ident

  attr_accessor :inbound_queue
  attr_accessor :outbound_queue
  attr_accessor :claimed_queue

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  # Creates a new Agent in the supplied context. Options can be specified for:
  #  * :ident - The identifier of this agent, will default if not specified.
  #  * :inbound_queue - The queue to service from.
  #  * :outbound_queue - Where jobs will be pushed to.
  def initialize(context, options = nil)
    @context = context

    @ident = options && options[:ident] || @context.generate_ident
    @repository = @context.repository

    @inbound_queue = options && options[:inbound_queue] || @context.queue(@ident)
    @outbound_queue = options && options[:outbound_queue] || @context.queue
    @claimed_queue = @context.queue("#{@ident}#{CLAIMED_POSTFIX}")
  end

  def running?
    !!@running
  end

  def start!
    @thread ||= Thread.new do
      Thread.abort_on_exception = true

      @running = true

      self.run!(5)
    end
  end

  def stop!
    return unless (@thread)

    @running = false

    @thread.kill
    @thread.join

    @thread = nil
  end

  # Makes a request to subscribe to queued items with the given tag. If the
  # repeat option is specified, then this request will persist even when
  # it has been serviced. This can be called multiple times which has the
  # effect of increasing the number of subscriptions accordingly.
  def subscribe(tag, repeat = false)
    self.request!(
      'subscribe' => tag.to_s,
      'repeat' => repeat
    )
  end

  # Makes a request to no longer receive queued items with the given tag.
  def unsubscribe(tag)
    self.request!(
      'unsubscribe' => tag.to_s
    )
  end

  # Pops an item from a given queue and places it in the claimed queue for
  # this agent.
  def pop!(queue, block = false)
    @repository.pop!(queue, self, block)
  end

  # Registers a claim on a given entity.
  def claim!(entity)
    entity.agent_ident = self.ident

    entity.save!
    entity.active!
  end

  # Releases a claim on a given entity.
  def release!(entity)
    entity.agent_ident = nil

    entity.save!
    entity.inactive!
  end

  # Queues a particular entity in 
  def queue!(job, queue = nil)
    job.agent_ident = @ident
    @repository.save!(job)

    @repository.queue!(job, queue)
  end

  # Pushes a request into the outbound queue.
  def request!(request)
    @outbound_queue.push!({
      :agent_ident => @ident
    }.merge(request))
  end
  
  # This initiates the main run loop of the Agent. If a timeout is passed in,
  # then a blocking call to fetch new work will be initiated with the specified
  # timeout.
  def run!(timeout = nil)
    loop do
      object = @inbound_queue.pop!(@claimed_queue, timeout)

      was_processed =
        case (object)
        when nil
          # Timed out during blocking pop call, so ignore
          false
        when Sprue::Job
          handle_job(object)
        when Sprue::Entity
          handle_entity(object)
        else
          handle_command(object)
        end

      if (was_processed)
        @claimed_queue.shift!(true)
      end

      break unless (@running)
    end
  end

protected
  # Defines how a job is handled. If the method returns true then the job is
  # considered to have been processed and will be removed from the claimed
  # queue.
  def handle_job(job)
    # Behavior defined in user-defined subclass
  end

  # Defines how an entity is handled. If the method returns true then the
  # entity is considered to have been processed and will be removed from the
  # claimed queue.
  def handle_entity(entity)
    # Behavior defined in user-defined subclass
  end

  # Defines how a command is handled. If the method returns true then the
  # command is considered to have been processed and will be removed from the
  # claimed queue.
  def handle_command(command)
    # Behavior defined in user-defined subclass
  end
end
