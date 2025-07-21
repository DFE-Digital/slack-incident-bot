# frozen_string_literal: true
require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList["{test,#{File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'test')}}/**/*_test.rb"].exclude("#{File.join(Gem.loaded_specs['kaminari-core'].gem_dir, 'test')}/requests/*_test.rb")
  t.warning = true
  t.verbose = true
end

task default: :test
