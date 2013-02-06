require_relative '../helper'

class TestSprueQueue < Test::Unit::TestCase
  def test_defaults
    queue = Sprue::Queue.new(:ident => 'test-ident')

    assert_equal 'test-ident', queue.ident
    assert_equal nil, queue.repository

    attributes = {
      :ident => 'test-ident'
    }

    assert_equal attributes, queue.attributes

    assert_equal false, queue.push!('test')
  end

  def test_with_name
    queue = Sprue::Queue.new(:ident => 'test-queue')

    assert_equal 'test-queue', queue.ident
  end

  class TestEntity < Sprue::Entity
  end

  def test_push_pop
    repository = Sprue::Repository.new(Sprue::Context.new.connection)

    queue = Sprue::Queue.new(:ident => 'test-queue')
    queue.save!(repository)

    assert_equal repository, queue.repository

    assert_equal 0, queue.length

    entity = TestEntity.new
    entity.save!(repository)

    assert_equal true, repository.exist?(entity)

    queue.push!(entity)

    assert_equal 1, queue.length

    popped = queue.pop!

    assert popped
    assert_equal entity.attributes, popped.attributes

    assert_equal 0, queue.length

    popped = queue.pop!

    assert_equal nil, popped
  end

  def test_push_pop_release
    repository = Sprue::Repository.new(Sprue::Context.new.connection)

    queue = Sprue::Queue.new(:ident => 'test-queue')
    queue.save!(repository)

    assert_equal 0, queue.length

    agent = Sprue::Agent.new(:ident => 'test-agent')
    agent.save!(repository)

    assert_equal 0, agent.claimed_count

    entity = TestEntity.new
    entity.save!(repository)

    assert_equal true, repository.exist?(entity)

    queue.push!(entity)

    assert_equal 1, queue.length

    popped = queue.pop!

    assert popped
    assert_equal entity.attributes, popped.attributes

    assert_equal 0, queue.length

    popped = queue.pop!

    assert_equal nil, popped
  end
end
