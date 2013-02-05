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

end
