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
