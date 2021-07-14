# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

# Rails.application.load_tasks

require 'rubygems'
require 'bundler/setup'

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end
rescue LoadError
end

require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

task default: ['db:create', 'db:migrate', :spec]
