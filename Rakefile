# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

# Rails.application.load_tasks

require 'rubygems'
require 'bundler/setup'

# require 'rspec/core'
# require 'rspec/core/rake_task'

require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

# RSpec::Core::RakeTask.new(:spec) do |spec|
#   spec.pattern = FileList['spec/**/*_spec.rb']
# end


task default: [:spec]
