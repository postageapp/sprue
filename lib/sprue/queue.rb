class Sprue::Queue < Sprue::Entity
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def push!(entity)
    @repository.push!(self, entity)
  end

  def pop!(to_queue = nil, block = false)
    @repository.pop!(self, to_queue, block)
  end

  def delete!(entity)
    @repository.pull!(self, entity)
  end

  def length
    @repository.length(self)
  end
  alias_method :size, :length
  alias_method :count, :length
end
