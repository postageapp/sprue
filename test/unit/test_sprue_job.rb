require_relative '../helper'

class TestSprueJob < Test::Unit::TestCase
  def test_defaults
    job = Sprue::Job.new

    assert_equal Sprue::Context.generate_ident.length, job.ident.length
    assert_equal nil, job.agent_ident
    assert_equal nil, job.queue
    assert_equal 1, job.priority
    assert_equal nil, job.scheduled_at
    assert_equal [ ], job.tags
    assert_equal nil, job.type
    assert_equal nil, job.data
  end

  def test_tags_independence
    job = Sprue::Job.new

    job.tags << 'test'

    assert_equal %w[ test ], job.tags

    job = Sprue::Job.new

    assert_equal [ ], job.tags
  end

  def test_attributes
    job = Sprue::Job.new(
      :ident => 'test-ident',
      :agent_ident => 'test-agent-ident',
      :scheduled_at => Time.at(1 << 30).utc,
      :queue => 'test-queue',
      :priority => 99,
      :tags => %w[ tag-a tag-b ],
      :type => 'test-type',
      :data => { :test => 'data' },
      :status => 'test-status'
    )

    expected = {
      :ident => 'test-ident',
      :agent_ident => 'test-agent-ident',
      :queue => 'test-queue',
      :scheduled_at => Time.at(1 << 30).utc,
      :priority => 99,
      :tags => %w[ tag-a tag-b ],
      :type => 'test-type',
      :data => { :test => 'data' },
      :status => 'test-status'
    }

    assert_equal expected, job.attributes

    assert_equal 'test-ident', job.ident
    assert_equal 'test-agent-ident', job.agent_ident
    assert_equal 'test-queue', job.queue
    assert_equal Time.at(1 << 30).utc, job.scheduled_at
    assert_equal 99, job.priority
    assert_equal %w[ tag-a tag-b ], job.tags
    assert_equal 'test-status', job.status

    data = { :test => 'data' }

    assert_equal data, job.data
  end
end
