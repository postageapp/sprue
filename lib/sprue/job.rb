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
  attribute :type,
    :as => :string
  attribute :data,
    :as => :json
  attribute :status

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  # Defines the action to be performed when this job is to be executed. The
  # worker executing this job can be passed in as an argument to provide
  # context.
  def perform(worker = nil)
    # Customized in sub-classes

    true
  end
end
