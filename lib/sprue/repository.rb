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

  def job_attributes_serialize(attributes)
    ident = attributes.delete(:ident)

    attributes[:scheduled_at] = attributes[:scheduled_at].to_i
    attributes[:tags] = attributes[:tags].join(',')
    attributes[:data] = attributes[:data] && JSON.dump(attributes[:data])

    attributes = attributes.to_a.flatten.collect { |v| v.to_s }

    return ident, attributes
  end

  def job_attributes_deserialize(ident, values)
    attributes = {
      :ident => ident
    }

    values.each_with_index do |key, i|
      next if (i % 2 == 1)
      
      value = values[i + 1]

      if (value and value.empty?)
        value = nil
      end

      case (key)
      when 'agent_ident'
        attributes[:agent_ident] = value
      when 'queue'
        attributes[:queue] = value
      when 'scheduled_at'
        attributes[:scheduled_at] = value && Time.at(value.to_i).utc
      when 'priority'
        attributes[:priority] = value.to_i
      when 'tags'
        attributes[:tags] = value ? value.split(/,/) : [ ]
      when 'data'
        attributes[:data] = value && JSON.load(value)
      when 'status'
        attributes[:status] = value
      end
    end

    attributes
  end

  def job_ident_key(ident)
    "job:#{ident}"
  end

  def job_exists?(ident)
    @connection.exists(job_ident_key(ident))
  end

  def job_load!(ident)
    values = @connection.hgetall(job_ident_key(ident))

    if (values.empty?)
      return
    end

    Sprue::Job.new(job_attributes_deserialize(ident, values.to_a.flatten), self)
  end

  def job_save!(job)
    ident, values = job_attributes_serialize(job.attributes)

    @connection.hmset(job_ident_key(ident), values)
  end
end
