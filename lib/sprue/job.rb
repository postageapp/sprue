class Sprue::Job < Sprue::Entity
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  # == Properties ===========================================================

  attribute :agent_ident
  attribute :queue
  attribute :scheduled_at,
    :as => :time
  attribute :priority,
    :as => :integer,
    :default => 1
  attribute :tags,
    :as => :csv
  attribute :data,
    :as => :json
  attribute :status

  attr_reader :repository

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def claim!(agent)
    @agent_ident = agent.ident

    self.save!
    self.active!
  end

  def release!
    @agent_ident = nil

    self.save!
    self.inactive!
  end

  def queue!(queue_name = nil)
    @repository.queue!(self, self.class, queue_name)
  end
end
