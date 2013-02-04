require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'redis'
require 'sprue'

class Test::Unit::TestCase
  def setup
    Sprue::Context.new.connection.flushdb
  end

  def assert_mapping(map)
    result_map = map.inject({ }) do |h, (k,v)|
      if (k and k.respond_to?(:freeze))
        k = k.freeze
      end
      h[k] = yield(k)
      h
    end
    
    differences = result_map.inject([ ]) do |a, (k,v)|
      if (v != map[k])
        a << k
      end
      a
    end
    
    assert_equal map, result_map, differences.collect { |s| "Input: #{s.inspect}\n  Expected: #{map[s].inspect}\n  Result:   #{result_map[s].inspect}\n" }.join('')
  end
end

Sprue::Context.config[:redis_database] = 1
