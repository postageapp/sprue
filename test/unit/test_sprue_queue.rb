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

    repository = Sprue::Context.new.repository
    queue.save!(repository)

    assert_equal false, queue.any?
    assert_equal true, queue.empty?
    assert_equal 0, queue.length
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

    claim_queue.remove!(entity)

    assert_equal 0, inbound_queue.length
    assert_equal 0, claim_queue.length
  end

  def test_push_remove_idents
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

    queue.remove!("TestEntity:1")

    assert_equal 1, queue.length
  end

  def test_push_remove
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

    queue.remove!(entities[1])
    queue.remove!(entities[3])
    queue.remove!(entities[5])

    assert_equal count - 3, queue.length
  end

  def test_push_shift_hashes
    context = Sprue::Context.new
    repository = context.repository

    queue = Sprue::Queue.new(:ident => 'inbound-queue')
    queue.save!(repository)

    items = [
      { 'test-0' => 'hash' }.freeze,
      { 'test-1' => 'hash' }.freeze,
      { 'test-2' => 'hash' }.freeze,
      { 'test-3' => 'hash' }.freeze,
      { 'test-4' => 'hash' }.freeze
    ].freeze

    items.each do |item|
      queue.push!(item)
    end

    # PUSH -> POP is FIFO
    popped = queue.pop!

    assert_equal items[0], popped

    # PUSH -> SHIFT is LIFO
    shifted = queue.shift!

    assert_equal items[4], shifted

    shifted = queue.shift!

    assert_equal items[3], shifted

    shifted = queue.shift!(true)

    assert_equal nil, shifted

    popped = queue.pop!

    assert_equal items[1], popped

    assert_equal 0, queue.length
  end
end
