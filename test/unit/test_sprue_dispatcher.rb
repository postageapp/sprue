require_relative '../helper'

class TestSprueDispatcher < Test::Unit::TestCase
  def test_defaults
    context = Sprue::Context.new

    dispatcher = Sprue::Dispatcher.new(context)

    assert_equal context, dispatcher.context

    assert_equal false, dispatcher.backlog?
    assert_equal 0, dispatcher.backlog_count

    assert_equal false, dispatcher.claimed?
    assert_equal 0, dispatcher.claimed_count
  end

  def test_run_cycle
    context = Sprue::Context.new
    dispatcher = Sprue::Dispatcher.new(context)

    assert_equal 0, dispatcher.inbound_queue.length

    dispatcher.inbound_queue.push!(
      'subscribe' => 'tag1',
      'agent_ident' => 'agent1'
    )

    assert_equal 1, dispatcher.inbound_queue.length

    background do
      dispatcher.run!(1)
    end

    assert_eventually do
      dispatcher.inbound_queue.empty?
    end

    assert_eventually do
      dispatcher.claimed_queue.empty?
    end

    assert_equal %w[ agent1 ], dispatcher.tag_subscribers('tag1')

    dispatcher.inbound_queue.push!(
      'subscribe' => 'tag1',
      'agent_ident' => 'agent2'
    )

    assert_eventually do
      dispatcher.inbound_queue.empty?
    end

    assert_equal %w[ agent1 agent2 ], dispatcher.tag_subscribers('tag1')    
  end
end
