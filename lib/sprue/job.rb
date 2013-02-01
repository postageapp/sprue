class Sprue::Job
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  DEFAULTS = {
    :ident => lambda { Sprue::Context.generate_ident },
    :priority => 1,
    :tags => lambda { [ ] }
  }
  
  # == Properties ===========================================================

  attr_accessor :ident
  attr_accessor :agent_ident
  attr_accessor :queue
  attr_accessor :scheduled_at
  attr_accessor :priority
  attr_accessor :tags
  attr_accessor :data
  attr_accessor :status

  attr_reader :repository

  # == Class Methods ========================================================

  def self.defaults
    DEFAULTS
  end
  
  # == Instance Methods =====================================================

  def initialize(options = nil, repository = nil)
    options = self.class.defaults.merge(options || { })

    options.each do |k, v|
      if (v.is_a?(Proc))
        options[k] = v.call
      end
    end

    @ident = options[:ident]
    @agent_ident = options[:agent_ident]
    @queue = options[:queue]
    @scheduled_at = options[:scheduled_at]
    @priority = options[:priority]
    @tags = options[:tags]
    @data = options[:data]
    @status = options[:status]

    @repository = repository
  end

  def claim!(agent)
    @agent_ident = agent.ident
    # ...
  end

  def queue!(queue_name)

  end

  def attributes
    {
      :ident => @ident,
      :agent_ident => @agent_ident,
      :queue => queue,
      :scheduled_at => @scheduled_at,
      :priority => @priority,
      :tags => @tags,
      :data => @data,
      :status => @status
    }
  end

  def save!(repository = nil)
    if (repository)
      @repository = repository
    end

    @repository.job_save!(self)
  end
end
