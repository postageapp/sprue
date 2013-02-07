class Sprue::Queue < Sprue::Entity
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def pop!(to_queue = nil, block = false)
    @repository.queue_pop!(self, to_queue, block)
  end

  def push!(entity)
    @repository.queue_push!(self, entity)
  end

  def pull!(entity)
    @repository.queue_pull!(self, entity)
  end

  def clear!
    @repository.queue_drop!(self)
  end

  def length
    @repository.queue_length(self)
  end
  alias_method :size, :length
  alias_method :count, :length
end
