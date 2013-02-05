class Sprue::Agent < Sprue::Entity
  # == Extensions ===========================================================

  # == Constants ============================================================

  # == Properties ===========================================================

  attribute :tags,
    :as => :csv

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize(context, ident = nil)
    super(ident)

    @client = Sprue::Client.new(context)

    if (block_given?)
      @handler = Proc.new
    end
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

  def claim!(agent)
    self.save!
    self.active!
  end

  def release!
    @agent_ident = nil

    self.save!
    self.inactive!
  end

  def queue!(job, queue_name = nil)
    job.agent_ident = @ident
    @repository.save!(job)

    @repository.queue!(self, self.class, queue_name)
  end

  def claim!(job)
    @repository.claim!(self, self.class, job, job.class)
  end

  def release!(job)
    @repository.release!(self, self.class, job, job.class)
  end
end
