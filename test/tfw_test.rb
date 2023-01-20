# frozen_string_literal: true

require 'test_helper'

class TfwTest < Minitest::Test
  WS = "#{TEST_DIR}/ws"

  def reset_workspace
    old_dir = Dir.pwd
    FileUtils.mkdir_p WS
    Dir.chdir WS
    Dir.glob('**/*', File::FNM_DOTMATCH)
       .grep_v(%r{.terraform/plugins|\.$})
       .reject { |f| File.directory? f }
       .each { |f| FileUtils.rm f }
    Dir.chdir old_dir
  end

  def test_that_it_has_a_version_number
    refute_nil ::TFW::VERSION
  end

  def test_it_loads_module
    ENV['TFW_AS_JSON'] = nil

    reset_workspace
    FileUtils.cp_r "#{TEST_DIR}/data/module-test/.", WS

    Dir.chdir WS

    TFW.cli ['init']
    TFW.cli ['apply', '-auto-approve']

    assert_equal File.read("#{WS}/.tfw/foo.bar"), 'foobar'
  end

  def test_it_loads_module_as_json
    ENV['TFW_AS_JSON'] = 'true'

    reset_workspace
    FileUtils.cp_r "#{TEST_DIR}/data/module-test/.", WS

    Dir.chdir WS

    TFW.cli ['init']
    TFW.cli ['apply', '-auto-approve']

    assert_equal File.read("#{WS}/.tfw/foo.bar"), 'foobar'
  end

  def test_it_traps_signals
    reset_workspace
    FileUtils.cp_r "#{TEST_DIR}/data/signal-trap-test/.", WS

    Dir.chdir WS

    TFW.cli ['init']

    pid = fork { TFW.cli ['apply', '-auto-approve'] }

    sleep 1
    Process.kill 'SIGTERM', pid
    Process.wait pid
    assert_equal 2, $?.exitstatus
  end
end
