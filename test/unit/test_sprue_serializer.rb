require_relative '../helper'

class TestSprueSerializer < Test::Unit::TestCase
  def test_hash_to_list
    assert_mapping(
      { :foo => 'bar' } => [ 'foo', 'bar' ],
      { :foo => nil } => [ 'foo', '' ],
      { } => [ ]
    ) do |hash|
      Sprue::Serializer.hash_to_list(hash)
    end
  end

  def test_list_to_hash
    assert_mapping(
      [ 'foo', 'bar' ] => { 'foo' => 'bar' },
      [ 'foo', '' ] => { 'foo' => '' },
      [ ] => { }
    ) do |list|
      Sprue::Serializer.list_to_hash(list)
    end
  end

  SAMPLE_OPTIONS = {
    :name => {
      :serialize => lambda { |v| v.to_s.upcase },
      :deserialize => lambda { |v| v.downcase }
    },
    :hex => {
      :serialize => lambda { |v| v ? v.to_s(16) : '' },
      :deserialize => lambda { |v| v.to_i(16) }
    },
    :blanked => {
      :serialize => lambda { |v| v.to_s.upcase },
      :deserialize => lambda { |v| v.downcase },
      :allow_blank => true
    }
  }.freeze

  def test_sample_defaults
    attributes = {
      :ident => 'test-ident'
    }

    values = [
      'test-ident',
      [
        'name', '',
        'hex', '',
        'blanked', ''
      ]
    ]

    assert_equal values, Sprue::Serializer.serialize(attributes[:ident], attributes, SAMPLE_OPTIONS)
  end

  def test_sample_data
    attributes = {
      :ident => 'test-ident',
      :name => :test,
      :hex => 32,
      :blanked => ''
    }

    values = [
      'test-ident',
      [
        'name', 'TEST',
        'hex', '20',
        'blanked', ''
      ]
    ]

    assert_equal values, Sprue::Serializer.serialize(attributes[:ident], attributes, SAMPLE_OPTIONS)
  end

  ENCODED_OPTIONS = {
    :string => {
      :serialize => lambda { |v| v.to_s },
      :deserialize => lambda { |v| v }
    },
    :integer => {
      :serialize => lambda { |v| v.to_s },
      :deserialize => lambda { |v| v.to_i }
    },
    :time => {
      :serialize => lambda { |v| v.to_i.to_s },
      :deserialize => lambda { |v| Time.at(v.to_i).utc }
    },
    :csv => {
      :serialize => lambda { |v| v.join(',') },
      :deserialize => lambda { |v| v.split(',') },
    },
    :json => {
      :serialize => lambda { |v| JSON.dump(v) },
      :deserialize => lambda { |v| JSON.load(v) }
    }
  }

  def test_encoding_example_defaults
    attributes = {
      :ident => 'test-ident'
    }

    values = [
      'test-ident',
      [
        'string', '',
        'integer', '',
        'time', '',
        'csv', '',
        'json', ''
      ]
    ]

    assert_equal values, Sprue::Serializer.serialize(attributes[:ident], attributes, ENCODED_OPTIONS)
  end

  def test_decoding_example_defaults
    values = [
      'string', '',
      'integer', '',
      'time', '',
      'csv', '',
      'json', ''
    ]

    attributes = {
      :ident => 'test-ident',
      :string => nil,
      :integer => nil,
      :time => nil,
      :csv => nil,
      :json => nil
    }

    assert_equal attributes, Sprue::Serializer.deserialize(attributes[:ident], values, ENCODED_OPTIONS)
  end

  def test_encoding_example_data
    attributes = {
      :ident => 'test-ident',
      :string => :test,
      :integer => 92,
      :time => Time.at(1 << 30).utc,
      :csv => %w[ a b c ],
      :json => { 'test' => [ 'things' ] }
    }

    values = [
      'test-ident',
      [
        'string', 'test',
        'integer', '92',
        'time', '1073741824',
        'csv', 'a,b,c',
        'json', '{"test":["things"]}'
      ]
    ]

    assert_equal values, Sprue::Serializer.serialize(attributes[:ident], attributes, ENCODED_OPTIONS)
  end

  def test_deencoding_example_data
    values = [
      'string', 'test',
      'integer', '92',
      'time', '1073741824',
      'csv', 'a,b,c',
      'json', '{"test":["things"]}'
    ]

    attributes = {
      :ident => 'test-ident',
      :string => 'test',
      :integer => 92,
      :time => Time.at(1 << 30).utc,
      :csv => %w[ a b c ],
      :json => { 'test' => [ 'things' ] }
    }

    assert_equal attributes, Sprue::Serializer.deserialize(attributes[:ident], values, ENCODED_OPTIONS)
  end
end
