require 'securerandom'

class Sprue::Context
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  CONFIG = {
    :redis_host => 'localhost',
    :redis_port => 6379,
    :redis_database => 0,
    :default_queue => 'default'
  }
  
  # == Properties ===========================================================

  attr_reader :redis_host
  attr_reader :redis_port
  attr_reader :redis_database
  attr_reader :default_queue
  
  # == Class Methods ========================================================

  def self.config
    CONFIG
  end
  
  def self.generate_ident
    '%012x%08x' % [
      Time.now.to_f * (1 << 16),
      SecureRandom.random_number(1 << 32)
    ]
  end

  # == Instance Methods =====================================================

  def initialize(config = nil)
    @redis_host = config && config[:redis_host] || CONFIG[:redis_host]
    @redis_port = config && config[:redis_port] || CONFIG[:redis_port]
    @redis_database = config && config[:redis_database] || CONFIG[:redis_database]

    @default_queue = config && config[:default_queue] || CONFIG[:default_queue]
  end

  def connection
    @connection ||= Sprue::Connection.new(self)
  end

  def repository
    @repository ||= Sprue::Repository.new(self.connection)
  end

  def queue(name = nil, save = true, cache = true)
    name ||= @default_queue

    if (cached_queue = cache && @queue && @queue[name])
      return cached_queue
    end

    new_queue = Sprue::Queue.new({ :ident => name }, self.repository)

    new_queue.save!

    if (cache)
      @queue ||= { }

      @queue[name.to_s] ||= new_queue
    end

    new_queue
  end

  def client
   Sprue::Client.new(self, self.repository, self.queue)
  end

  def generate_ident
    self.class.generate_ident
  end
end
