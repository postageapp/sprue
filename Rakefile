# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = "sprue"
  gem.homepage = "http://github.com/tadman/sprue"
  gem.license = "MIT"
  gem.summary = %Q{Simple Job Queue}
  gem.description = %Q{A simple job queueing system for people who might need to queue a lot of jobs.}
  gem.email = "scott@twg.ca"
  gem.authors = [ "Scott Tadman" ]
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
