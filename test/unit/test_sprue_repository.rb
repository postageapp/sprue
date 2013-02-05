require_relative '../helper'

class TestSprueRepository < Test::Unit::TestCase
  def test_defaults
    context = Sprue::Context.new

    repository = Sprue::Repository.new(context.connection)

    assert_equal repository.context, context
  end

  def test_queue_length
    repository = Sprue::Repository.new(Sprue::Context.new.connection)

    assert_equal 0, repository.length('Sprue::Queue#default*')
  end

  def test_base_entity_save_and_load
    repository = Sprue::Repository.new(Sprue::Context.new.connection)

    entity = Sprue::Entity.new(
      :ident => 'test-ident'
    )

    assert_equal false, repository.exist?(entity)

    repository.save!(entity)

    assert_equal true, repository.exist?(entity)
  end

  class DataEntity < Sprue::Entity
    attribute :data, :as => :json
  end

  def test_data_entity_save_and_load
    repository = Sprue::Repository.new(Sprue::Context.new.connection)

    entity = DataEntity.new(
      :ident => 'test-ident',
      :data => { 'test' => 'data' }
    )

    assert_equal nil, entity.repository

    assert_equal false, repository.exist?(entity)
    assert_equal false, repository.active?(entity)
    assert_equal nil, repository.load!(DataEntity.repository_key('test-ident'))

    repository.save!(entity)

    assert_equal nil, entity.repository

    assert_equal true, repository.exist?(entity)
    assert_equal false, repository.active?(entity)

    repository.active!(entity)

    assert_equal true, repository.active?(entity)

    repository.inactive!(entity)

    assert_equal false, repository.active?(entity)

    repository.active!(entity)

    assert_equal true, repository.active?(entity)

    loaded_entity = repository.load!(DataEntity.repository_key('test-ident'))

    assert_equal entity.attributes, loaded_entity.attributes
    assert_equal repository, loaded_entity.repository

    repository.delete!(entity)

    assert_equal false, repository.exist?(entity)
    assert_equal false, repository.active?(entity)
    assert_equal nil, repository.load!(DataEntity.repository_key('test-ident'))
  end
end
