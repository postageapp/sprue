require_relative '../helper'

class TestSprueEntity < Test::Unit::TestCase
  class SampleEntity < Sprue::Entity
    attribute :string
    attribute :integer,
      :as => :integer
    attribute :json,
      :as => :json
    attribute :csv,
      :as => :csv
  end

  def test_sample_entity_attributes
    entity = SampleEntity.new(:ident => 'test-ident')

    assert entity.class.attributes

    assert_equal nil, entity.repository

    attributes = {
      :ident => 'test-ident',
      :string => nil,
      :integer => nil,
      :json => nil,
      :csv => [ ]
    }

    assert_equal attributes, entity.attributes
  end

  def test_sample_entity_cast_on_assignment
    entity = SampleEntity.new

    entity.ident = 'test-ident'
    entity.string = :test
    entity.integer = '-10.29'
    entity.json = %w[ test ]
    entity.csv = 'item'

    attributes = {
      :ident => 'test-ident',
      :string => 'test',
      :integer => -10,
      :json => [ 'test' ],
      :csv => [ 'item' ]
    }

    assert_equal attributes, entity.attributes
  end

  def test_sample_entity_save
    entity = SampleEntity.new

    repository = Sprue::Context.new.repository

    assert_equal false, repository.exist?(entity)

    entity.save!(repository)

    assert_equal true, repository.exist?(entity)

    entity.delete!(repository)

    assert_equal false, repository.exist?(entity)

    assert_equal nil, repository.load!(entity.ident, entity.class)
  end

  class WithDefaultsEntity < Sprue::Entity
    attribute :string,
      :default => 'empty'
    attribute :integer,
      :as => :integer,
      :default => 0
    attribute :json,
      :as => :json,
      :default => lambda { { } }
    attribute :csv,
      :as => :csv,
      :default => lambda { %w[ item ] }
  end

  def test_with_defaults_entity_attributes
    entity = WithDefaultsEntity.new(:ident => 'test-ident')

    attributes = {
      :ident => 'test-ident',
      :string => 'empty',
      :integer => 0,
      :json => { },
      :csv => %w[ item ]
    }

    assert_equal attributes, entity.attributes
  end

  def test_with_defaults_entity_attributes_using_casting
    entity = WithDefaultsEntity.new(
      :ident => 'test-ident',
      :string => :test,
      :integer => '-10',
      :json => { 'test' => 'item' },
      :csv => 'item'
    )

    attributes = {
      :ident => 'test-ident',
      :string => 'test',
      :integer => -10,
      :json => { 'test' => 'item' },
      :csv => %w[ item ]
    }

    assert_equal 'test-ident', entity.ident

    assert_equal attributes, entity.attributes

    assert entity.ident

    repository = Sprue::Context.new.repository

    assert_equal false, repository.exist?(entity)

    entity.save!(repository)

    loaded_entity = repository.load!(entity, entity.class)

    assert_equal attributes, loaded_entity.attributes
  end
end
