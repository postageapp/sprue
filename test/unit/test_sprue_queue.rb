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
  end

  def test_with_name
    queue = Sprue::Queue.new(:ident => 'test-queue')

    assert_equal 'test-queue', queue.ident
  end

  class TestEntity < Sprue::Entity
  end

  def test_push_pop
    repository = Sprue::Context.new.repository

    queue = Sprue::Queue.new({ :ident => 'test-queue' }, repository)
    queue.save!

    assert_equal repository, queue.repository

    assert_equal 0, queue.length

    entity = TestEntity.new
    entity.save!(repository)

    assert_equal true, repository.entity_exist?(entity)

    queue.push!(entity)

    assert_equal 1, queue.length

    popped = queue.pop!

    assert popped
    assert_equal entity.attributes, popped.attributes

    assert_equal 0, queue.length

    popped = queue.pop!

    assert_equal nil, popped
  end

  def test_push_pop_to_queue
    context = Sprue::Context.new
    repository = context.repository

    inbound_queue = Sprue::Queue.new({ :ident => 'inbound-queue' }, repository)
    inbound_queue.save!

    assert_equal 0, inbound_queue.length

    claim_queue = Sprue::Queue.new({ :ident => 'claim-queue' }, repository)
    claim_queue.save!

    entity = TestEntity.new
    entity.save!(repository)

    assert_equal true, repository.entity_exist?(entity)

    inbound_queue.push!(entity)

    assert_equal 1, inbound_queue.length

    popped = inbound_queue.pop!(claim_queue)

    assert popped
    assert_equal entity.attributes, popped.attributes

    assert_equal 0, inbound_queue.length
    assert_equal 1, claim_queue.length

    popped = inbound_queue.pop!(claim_queue)

    assert_equal nil, popped

    assert_equal 0, inbound_queue.length
    assert_equal 1, claim_queue.length

    claim_queue.pull!(entity)

    assert_equal 0, inbound_queue.length
    assert_equal 0, claim_queue.length
  end

  def test_push_pull
    context = Sprue::Context.new
    repository = context.repository

    queue = Sprue::Queue.new(:ident => 'inbound-queue')
    queue.save!(repository)

    assert_equal 0, queue.length

    queue.push!("TestEntity:1")
    queue.push!("TestEntity:1")
    queue.push!("TestEntity:2")
    queue.push!("TestEntity:1")

    assert_equal 4, queue.length

    queue.pull!("TestEntity:1")

    assert_equal 1, queue.length
  end

  def test_push_pull
    context = Sprue::Context.new
    repository = context.repository

    queue = Sprue::Queue.new(:ident => 'inbound-queue')
    queue.save!(repository)

    assert_equal 0, queue.length

    count = 100

    entities = (1..count).to_a.collect { |n| "TestEntity:#{n}" }

    entities.each do |entity|
      queue.push!(entity)
    end

    assert_equal count, queue.length

    queue.pull!(entities[1])
    queue.pull!(entities[3])
    queue.pull!(entities[5])

    assert_equal count - 3, queue.length
  end
end
