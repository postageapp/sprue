require 'json'

class Sprue::Repository
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  # == Properties ===========================================================

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(connection)
    @connection = connection
  end

  def context
    @connection.context
  end

  def job_metadata_key(ident)
    "job:#{ident}"
  end

  def job_exists?(ident)
    @connection.exists(job_metadata_key(ident))
  end

  def job_load!(ident)
    values = @connection.hgetall(job_metadata_key(ident))

    if (values.empty?)
      return
    end

    Sprue::Job.new(Sprue::Serializer::Job.deserialize(ident, values), self)
  end

  def job_save!(job)
    ident, values = Sprue::Serializer::Job.serialize(job.attributes)

    @connection.hmset(job_metadata_key(ident), values)
  end

  def agent_metadata_key(ident)
    "agent:#{ident}"
  end

  def agent_active_key(ident)
    "agent:#{ident}!"
  end

  def agent_exists?(ident)
    @connection.exists(agent_metadata_key(ident))
  end

  def agent_active?(ident)
    @connection.exists(agent_active_key(ident))
  end

  def agent_load!(ident)

  end

  def agent_update!(agent)
  end

  def agent_remove!(agent)
  end
end
