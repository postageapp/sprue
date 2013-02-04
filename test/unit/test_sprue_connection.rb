require_relative '../helper'

class TestSprueConnection < Test::Unit::TestCase
  def test_defaults
    context = Sprue::Context.new

    connection = Sprue::Connection.new(context)

    assert_equal true, connection.respond_to?(:get)
  end
end
