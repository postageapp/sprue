class Sprue::Agent < Sprue::Entity
  # == Extensions ===========================================================

  # == Constants ============================================================

  # == Properties ===========================================================

  attr_accessor :inbound_queue
  attr_accessor :outbound_queue
  attr_accessor :claim_queue

  attribute :tags,
    :as => :csv

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize(context, ident = nil, inbound_queue = nil, outbound_queue = nil)
    @context = context

    super({ :ident => ident }, @context.repository)

    @inbound_queue = inbound_queue || @context.queue("#{@ident}~i")
    @outbound_queue = outbound_queue || @context.queue
    @claim_queue = @context.queue("#{@ident}~c")

    if (block_given?)
      @handler = Proc.new
    end
  end

  def subscribe(tag)
    @tags << tag
    @tags.uniq!

    @repository.subscribe!(tag, self)
  end

  def unsubscribe(tag)
    @tags.delete(tag)

    @repository.unsubscribe!(tag, self)
  end

  def receive(job)
    @handler.call(job)
  end

  def pop!(queue, block = false)
    @repository.pop!(queue, self, block)
  end

  def claim!(entity)
    entity.agent_ident = self.ident
    entity.save!

    entity.active!
  end

  def release!(entity)
    @agent_ident = nil

    self.save!
    self.inactive!
  end

  def queue!(job, queue = nil)
    job.agent_ident = @ident
    @repository.save!(job)

    @repository.queue!(job, queue)
  end

  def claim!(job)
    @repository.claim!(self, self.class, job, job.class)
  end

  def release!(job)
    @repository.release!(self, self.class, job, job.class)
  end
end
