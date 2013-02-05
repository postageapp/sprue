class Sprue::Queue < Sprue::Entity
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def push!(entity, entity_class = nil)
    return false unless (@repository)
    
    @repository.push!(self, entity)
  end

  def pop!(agent = nil, block = false)
    return false unless (@repository)

    @repository.pop!(self, agent, block)
  end

  def release!(entity, agent = nil)
    return false unless (@repository)

    @repository.release!(entity, agent)
  end

  def length
    return false unless (@repository)

    @repository.length(self)
  end
end
