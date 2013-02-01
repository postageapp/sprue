class Sprue::Client
  # == Extensions ===========================================================

  # == Constants ============================================================

  # == Properties ===========================================================

  attr_reader :context
  attr_reader :repository

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize(context, repository = nil)
    @context = context
    @repository = repository || @context.repository
  end

  def submit!(job)
    @repository.job_submit!(job)
  end
end
