class Sprue::Dispatcher < Sprue::Agent
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(context, ident = nil)
    super(context, ident)
  end

  def receive(job)
    @handler.call(job)
  end
end
