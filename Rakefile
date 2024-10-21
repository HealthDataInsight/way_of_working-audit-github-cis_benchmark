# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'way_of_working/tasks'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = false
  t.warning = false
end

desc 'Run tests'
task default: :test
