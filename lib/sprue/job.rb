class Sprue::Job < Sprue::Entity
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  DEFAULTS = {
    :ident => lambda { Sprue::Context.generate_ident },
    :priority => 1,
    :tags => lambda { [ ] }
  }
  
  # == Properties ===========================================================

  attribute :agent_ident
  attribute :queue
  attribute :scheduled_at,
    :as => :time
  attribute :priority,
    :as => :integer
  attribute :tags,
    :as => :csv
  attribute :data,
    :as => :json
  attribute :status

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
    # ...
  end
end
