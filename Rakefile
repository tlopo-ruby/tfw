# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'coveralls/rake/task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: %i[rubocop test]

task default: %i[rubocop test]
task test_with_coveralls: [:default, 'coveralls:push']

RuboCop::RakeTask.new
Coveralls::RakeTask.new
