class Sprue::Worker < Sprue::Agent
  # == Extensions ===========================================================

  # == Constants ============================================================

  # == Properties ===========================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

protected
  def handle_job(job)
    job.perform(self) and job.delete!

    true
  end
end
