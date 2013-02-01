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

  class SampleSerializer < Sprue::Serializer
    attribute :name,
      :serialize => lambda { |v| v.to_s.upcase },
      :deserialize => lambda { |v| v.downcase }
    attribute :hex,
      :serialize => lambda { |v| v ? v.to_s(16) : '' },
      :deserialize => lambda { |v| v.to_i(16) }

    attribute :blanked,
      :allow_blank => true
  end

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

    assert_equal values, SampleSerializer.serialize(attributes)
  end

  def test_sample_data
    serializer = SampleSerializer.new

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

    assert_equal values, serializer.serialize(attributes)
  end

  class EncodingExampleSerializer < Sprue::Serializer
    attribute :string, :as => :string
    attribute :integer, :as => :integer
    attribute :time, :as => :time
    attribute :csv, :as => :csv
    attribute :json, :as => :json
  end

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

    assert_equal values, EncodingExampleSerializer.serialize(attributes)
  end

  def test_decoding_example_defaults
    attributes = {
      :ident => 'test-ident',
      :string => nil,
      :integer => nil,
      :time => nil,
      :csv => [ ],
      :json => nil
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

    assert_equal attributes, EncodingExampleSerializer.deserialize(*values)
  end

  def test_encoding_example_data
    attributes = {
      :ident => 'test-ident',
      :string => :test,
      :integer => 92,
      :time => Time.at(1 << 30),
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

    assert_equal values, EncodingExampleSerializer.serialize(attributes)
  end

  def test_deencoding_example_data
    attributes = {
      :ident => 'test-ident',
      :string => 'test',
      :integer => 92,
      :time => Time.at(1 << 30),
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

    assert_equal attributes, EncodingExampleSerializer.deserialize(*values)
  end
end
