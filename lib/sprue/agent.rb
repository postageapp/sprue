class Sprue::Agent < Sprue::Client
  # == Extensions ===========================================================

  # == Constants ============================================================

  # == Properties ===========================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize(context, ident = nil)
    super(context)

    @feeder = context.feeder(self)
    @ident = ident || @context.generate_client_ident

    if (block_given?)
      @handler = Proc.new
    end
  end

  def subscribe(tag)
    @repository.client_subscribe!(self, tag)
  end

  def unsubscribe(tag)
    @repository.client_unsubscribe!(self, tag)
  end

  def receive(job)
    @handler.call(job)
  end

  def submit(job)
  end

protected
  def heartbeat!
    @
  end
end
