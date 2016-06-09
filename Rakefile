require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'semmy'

RSpec::Core::RakeTask.new(:spec)

Semmy::Tasks.install

task :default => :spec
