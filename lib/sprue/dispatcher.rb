class Sprue::Dispatcher
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  attr_reader :context

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(context)
    @context = context

    @client = @context.client
  end
end
