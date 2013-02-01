class Sprue::Serializer::Job < Sprue::Serializer
  # == Attributes ===========================================================
  
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
end
