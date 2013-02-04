class Sprue::Queue < Sprue::Entity
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def push!(entity, entity_class = nil)
    @repository and @repository.push!(entity, entity_class, self) or false
  end

  def length
    @repository and @repository.queue_length(ident)
  end
end
