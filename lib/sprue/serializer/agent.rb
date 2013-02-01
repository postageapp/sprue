class Sprue::Serializer::Agent < Sprue::Serializer
  attribute :tags,
    :as => :csv
end
