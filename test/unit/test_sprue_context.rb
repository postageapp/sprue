require_relative '../helper'

class TestSprueContext < Test::Unit::TestCase
  def test_generate_ident
    ident = Sprue::Context.generate_ident

    assert ident
    assert_equal 20, ident.length
    assert_equal '', ident.gsub(/[a-f0-9]/, '')
  end

  def test_defaults
    context = Sprue::Context.new

    assert context

    assert_equal Sprue::Context.config[:redis_host], context.redis_host
    assert_equal Sprue::Context.config[:redis_port], context.redis_port
    assert_equal Sprue::Context.config[:redis_database], context.redis_database
  end

  def test_connection
    context = Sprue::Context.new

    connection = context.connection

    assert connection

    assert_equal context, connection.context

    assert connection.respond_to?(:get)
  end

  def test_repository
    context = Sprue::Context.new

    repository = context.repository

    assert_equal context, repository.context
  end

  def test_queue
    context = Sprue::Context.new

    queue = context.queue

    assert_equal 'default', queue.ident

    assert_equal true, context.repository.entity_exist?(queue)
    assert_equal 0, queue.length
  end
end
