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

    @inbound_queue = @context.queue
  end

  def backlog?
    @inbound_queue.any?
  end

  def backlog_count
    @inbound_queue.length
  end
end
