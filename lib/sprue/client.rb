class Sprue::Client
  # == Extensions ===========================================================

  # == Constants ============================================================

  # == Properties ===========================================================

  attr_reader :context
  attr_reader :repository
  
  attr_accessor :outbound_queue

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize(context, repository = nil, outbound_queue = nil)
    @context = context
    @repository = repository || @context.repository
    
    @outbound_queue = outbound_queue || @context.default_queue
  end

  def push!(job)
    @queue and @queue.push!(job) or false
  end
end
