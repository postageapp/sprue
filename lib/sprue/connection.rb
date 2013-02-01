class Sprue::Connection < Redis
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  attr_reader :context
    
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(context)
    @context = context

    super(
      :host => context.redis_host,
      :port => context.redis_port,
      :database => context.redis_database
    )
  end
end
