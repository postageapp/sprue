class Sprue::Agent < Sprue::Client
  # == Extensions ===========================================================

  # == Constants ============================================================

  # == Properties ===========================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize(context, ident = nil)
    super(context)

    @ident = ident || @context.generate_client_ident
    @tags = [ ]

    if (block_given?)
      @handler = Proc.new
    end
  end

  def attributes
    {
      :ident => @ident,
      :tags => @tags
    }
  end

  def subscribe(tag)
    @tags << tag
    @tags.uniq!

    @repository.client_subscribe!(self, tag)
  end

  def unsubscribe(tag)
    @tags.delete(tag)

    @repository.client_unsubscribe!(self, tag)
  end

  def receive(job)
    @handler.call(job)
  end

  def job_queue!(job, queue = nil)
    @repository.job_save!(job)
    @repository.job_queue!(job, queue)
  end

  def update!
    @repository.agent_update!(self)
  end

  def remove!
    @repository.agent_remove!(self)
  end
end
