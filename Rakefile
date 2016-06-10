require "bundler/gem_tasks"
require "codeclimate-test-reporter"
require 'coveralls'
require 'scrutinizer/ocular'

begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:spec)
  task default: :spec

  Coveralls.wear!
  CodeClimate::TestReporter.start
  Scrutinizer::Ocular.watch!
rescue LoadError
end
