require_relative '../helper'

class TestSprueSortedArray < Test::Unit::TestCase
  def test_defaults
    array = Sprue::SortedArray.new

    assert_equal [ ], array
  end

  def test_insertion
    count = 10000
    test_data = (1..count).sort_by { rand }

    array = Sprue::SortedArray.new

    test_data.each do |i|
      array << i
    end

    assert_equal (1..count).to_a, array
  end

  class ExampleSortable
    def self.factor
      @factor ||= 1
    end

    def self.factor=(v)
      @factor = v
    end

    def initialize(n)
      @n = n
    end

    def n
      @n * self.class.factor
    end

    def <=>(e)
      self.n <=> e.n
    end

    def >(e)
      self.n > e.n
    end

    def ==(e)
      self.n == e.n
    end
  end

  def test_resorting
    count = 10
    array = Sprue::SortedArray.new

    test_data = (1..count).sort_by { rand }

    test_data.each do |n|
      array << ExampleSortable.new(n)
    end

    assert_equal test_data.sort, array.collect(&:n)

    ExampleSortable.factor = -1

    array.sort!

    ExampleSortable.factor = 1

    assert_equal test_data.sort.reverse, array.collect(&:n)
  end
end
