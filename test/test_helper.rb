# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'pry'
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.minimum_coverage 95
SimpleCov.start

require 'tfw'
require 'tempfile'
require 'fileutils'
require 'minitest/autorun'

TEST_DIR = File.expand_path __dir__
