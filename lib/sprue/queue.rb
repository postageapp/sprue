class Sprue::Queue < Sprue::Entity
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def push!(entity, entity_class = nil)
    return false unless (@repository)
    
    @repository.push!(entity, entity_class, self)
  end

  def pop!(block = false)
    return false unless (@repository)

    @repository.pop!(self, nil, block)
  end

  def length
    @repository and @repository.queue_length(ident)
  end
end
