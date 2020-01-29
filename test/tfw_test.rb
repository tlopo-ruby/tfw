# frozen_string_literal: true

require 'test_helper'

class TfwTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TFW::VERSION
  end

  def test_it_loads_module
    ENV['TFW_AS_JSON'] = nil

    ws = "#{TEST_DIR}/ws"
    FileUtils.rm_rf "#{ws}/.tfw/foo.bar"
    FileUtils.mkdir_p ws
    FileUtils.cp_r "#{TEST_DIR}/data/.", ws

    Dir.chdir ws

    TFW.cli ['init']
    TFW.cli ['apply', '-auto-approve']

    assert_equal File.read("#{ws}/.tfw/foo.bar"), 'foobar'
  end

  def test_it_loads_module_as_json
    ENV['TFW_AS_JSON'] = 'true'
    ws = "#{TEST_DIR}/ws"
    FileUtils.rm_rf "#{ws}/.tfw/foo.bar"
    FileUtils.mkdir_p ws
    FileUtils.cp_r "#{TEST_DIR}/data/.", ws

    Dir.chdir ws

    TFW.cli ['init']
    TFW.cli ['apply', '-auto-approve']

    assert_equal File.read("#{ws}/.tfw/foo.bar"), 'foobar'
  end
end
