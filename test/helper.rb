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

Sprue::Context.config[:redis_database] = 1

class Test::Unit::TestCase
  def setup
    Sprue::Context.new.connection.flushdb
  end

  def teardown
    if (@threads)
      @threads.each do |thread|
        thread.kill
        thread.join
      end
    end
  end

  def background
    @threads ||= [ ]
    
    @threads << Thread.new do
      Thread.abort_on_exception = true
      
      yield
    end
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

  def assert_eventually(timeout = 1, message = nil)
    start = Time.now

    while (!yield)
      sleep(0.2)

      if (Time.now.to_f - start.to_f > timeout)
        fail(message || 'Timed out waiting for condition to become true')
      end
    end
  end
end
