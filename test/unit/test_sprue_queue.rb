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
    queue = Sprue::Queue.new(:ident => 'test')

    assert_equal 'test', queue.ident
  end

  class TestEntity < Sprue::Entity
  end

  def test_push
    repository = Sprue::Repository.new(Sprue::Context.new.connection)

    queue = Sprue::Queue.new(:ident => 'test')
    queue.save!(repository)

    assert_equal repository, queue.repository

    assert_equal nil, queue.length

    entity = TestEntity.new

    queue.push!(entity)

    assert_equal 1, queue.length

    
  end
end
