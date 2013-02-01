require_relative '../helper'

class TestSprueRepository < Test::Unit::TestCase
  def setup
    Sprue::Context.new.connection.flushdb
  end

  def test_defaults
    context = Sprue::Context.new

    repository = Sprue::Repository.new(context.connection)

    assert_equal repository.context, context
  end

  def test_job_attributes_serialize
    context = Sprue::Context.new

    repository = Sprue::Repository.new(context.connection)

    job = Sprue::Job.new(
      :ident => 'test-ident',
      :agent_ident => 'test-agent-ident',
      :queue => 'test-queue',
      :scheduled_at => Time.at(1 << 30).utc,
      :priority => 99,
      :tags => %w[ tag-a tag-b ],
      :data => { :test => 'data' },
      :status => 'test-status'
    )

    attributes = [
      'agent_ident', 'test-agent-ident',
      'queue', 'test-queue',
      'scheduled_at', (1 << 30).to_s,
      'priority', '99',
      'tags', 'tag-a,tag-b',
      'data', '{"test":"data"}',
      'status', 'test-status'
    ]

    assert_equal [ 'test-ident', attributes ], repository.job_attributes_serialize(job.attributes)
  end

  def test_job_attributes_deserialize_default_values
    context = Sprue::Context.new

    repository = Sprue::Repository.new(context.connection)

    values = [
      'agent_ident', '',
      'queue', '',
      'scheduled_at', '',
      'priority', '1',
      'tags', '',
      'data', '',
      'status', ''
    ]

    expected = {
      :ident => 'test-ident',
      :agent_ident => nil,
      :queue => nil,
      :scheduled_at => nil,
      :priority => 1,
      :tags => [ ],
      :data => nil,
      :status => nil
    }

    assert_equal expected, repository.job_attributes_deserialize('test-ident', values)
  end

  def test_job_attributes_deserialize_all_values
    context = Sprue::Context.new

    repository = Sprue::Repository.new(context.connection)

    values = [
      'agent_ident', 'test-agent-ident',
      'queue', 'test-queue',
      'scheduled_at', (1 << 30).to_s,
      'priority', '99',
      'tags', 'tag-a,tag-b',
      'data', '{"test":"data"}',
      'status', 'test-status'
    ]

    expected = {
      :ident => 'test-ident',
      :agent_ident => 'test-agent-ident',
      :queue => 'test-queue',
      :scheduled_at => Time.at(1 << 30).utc,
      :priority => 99,
      :tags => %w[ tag-a tag-b ],
      :data => { 'test' => 'data' },
      :status => 'test-status'
    }

    assert_equal expected, repository.job_attributes_deserialize('test-ident', values)
  end

  def test_job_save_and_load
    context = Sprue::Context.new

    repository = Sprue::Repository.new(context.connection)

    job = Sprue::Job.new(
      :ident => 'test-ident',
      :agent_ident => 'test-agent-ident',
      :queue => 'test-queue',
      :scheduled_at => Time.at(1 << 30).utc,
      :priority => 99,
      :tags => %w[ tag-a tag-b ],
      :data => { 'test' => 'data' },
      :status => 'test-status'
    )

    assert_equal nil, job.repository

    assert_equal false, repository.job_exists?(job.ident)
    assert_equal nil, repository.job_load!('test-ident')

    repository.job_save!(job)

    assert_equal nil, job.repository

    assert_equal true, repository.job_exists?(job.ident)

    loaded_job = repository.job_load!('test-ident')

    assert_equal job.attributes, loaded_job.attributes
    assert_equal repository, loaded_job.repository
  end
end
