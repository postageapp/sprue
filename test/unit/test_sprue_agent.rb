require_relative '../helper'

class TestSprueAgent < Test::Unit::TestCase
  def test_defaults
    context = Sprue::Context.new

    agent = Sprue::Agent.new(context)

    assert_equal context, agent.context
  end

  def test_request
    context = Sprue::Context.new

    agent = Sprue::Agent.new(context, :ident => 'test-agent')

    agent.request!(:subscribe => 'test-tag')

    queue = context.queue

    assert_equal 1, queue.length

    request = {
      'agent_ident' => 'test-agent',
      'subscribe' => 'test-tag'
    }

    assert_equal request, queue.pop!
  end
end
