require_relative '../helper'

class TestSprueSerializerJob < Test::Unit::TestCase
  def test_job_attributes_serialize
    attributes = {
      :ident => 'test-ident',
      :agent_ident => 'test-agent-ident',
      :queue => 'test-queue',
      :scheduled_at => Time.at(1 << 30).utc,
      :priority => 99,
      :tags => %w[ tag-a tag-b ],
      :data => { :test => 'data' },
      :status => 'test-status'
    }

    values = [
      'test-ident',
      [
        'agent_ident', 'test-agent-ident',
        'queue', 'test-queue',
        'scheduled_at', (1 << 30).to_s,
        'priority', '99',
        'tags', 'tag-a,tag-b',
        'data', '{"test":"data"}',
        'status', 'test-status'
      ]
    ]

    assert_equal values, Sprue::Serializer::Job.serialize(attributes)
  end

  def test_job_attributes_deserialize_default_values
    values = [
      'test-ident',
      [
        'agent_ident', '',
        'queue', '',
        'scheduled_at', '',
        'priority', '1',
        'tags', '',
        'data', '',
        'status', ''
      ]
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

    assert_equal expected, Sprue::Serializer::Job.deserialize(*values)
  end

  def test_job_attributes_deserialize_all_values
    values = [
      'test-ident',
      [
        'agent_ident', 'test-agent-ident',
        'queue', 'test-queue',
        'scheduled_at', (1 << 30).to_s,
        'priority', '99',
        'tags', 'tag-a,tag-b',
        'data', '{"test":"data"}',
        'status', 'test-status'
      ]
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

    assert_equal expected, Sprue::Serializer::Job.deserialize(*values)
  end
end
