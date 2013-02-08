require_relative '../helper'

class TestSprueDispatcher < Test::Unit::TestCase
  def test_defaults
    context = Sprue::Context.new

    dispatcher = Sprue::Dispatcher.new(context)

    assert_equal context, dispatcher.context

    assert_equal false, dispatcher.backlog?
    assert_equal 0, dispatcher.backlog_count
  end

  def test_run_cycle
    # ...
  end
end
