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
    dispatcher = Sprue::Dispatcher.new(Sprue::Context.new)

    dispatcher.start!

    context = Sprue::Context.new
    queue = context.queue

    queue.push!(
      'subscribe' => 'tag1',
      'agent_ident' => 'agent1'
    )

    assert_eventually do
      queue.empty?
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

    dispatcher.stop!
  end

  def test_echo
    dispatcher = Sprue::Dispatcher.new(Sprue::Context.new)

    dispatcher.start!

    agent = 'test-agent'

    context = Sprue::Context.new
    repository = context.repository
    outbound_queue = context.queue
    
    100.times do |n|
      echo = {
        'echo' => n.to_s,
        'agent_ident' => agent
      }

      outbound_queue.push!(echo)

      response = nil

      assert_eventually do
        response = repository.queue_pop!(agent, nil, 1)
      end

      assert_equal echo, response
    end
  end
end
