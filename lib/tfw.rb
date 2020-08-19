# frozen_string_literal: true

require 'tfw/version'
require 'tfdsl'
require 'json'
require 'singleton'
require_relative 'tfw/state'

# TFW is a Terraform Wrapper which uses terraform DSL for Ruby
module TFW
  module_function

  LIB_DIR = "#{__dir__}/tfw/"

  require "#{LIB_DIR}/setters"
  require "#{LIB_DIR}/module"
  require "#{LIB_DIR}/aws_sg_workaround"

  WORKSPACE = './.tfw'
  FileUtils.mkdir_p WORKSPACE

  def as_json?
    !ENV['TFW_AS_JSON'].nil?
  end

  def get_stack_for_dir(dir, input = nil, stack = State.instance.stack)
    configure_methods_using_stack stack
    configure_input_method input

    files = Dir.glob "#{dir}/*.rb"
    files.sort.each { |f| load f }
    configure_methods_using_stack State.instance.stack
    stack
  end

  def cli(args)
    build_config
    State.instance.reset
    run_terraform args
  end

  def build_config
    FileUtils.mkdir_p WORKSPACE
    stack = TFW.get_stack_for_dir '.'
    stack_file = "#{WORKSPACE}/stack.tf"
    write_stack_file stack_file, stack
  end

  def run_terraform(args)
    old_dir = Dir.pwd
    Dir.chdir WORKSPACE

    cmd = "terraform #{args.join ' '}"
    pid = fork { exec cmd }
    Dir.chdir old_dir
    trap_pids [pid]
    Process.wait pid
    $?.exitstatus
  end

  def trap_pids(pids)
    %w[SIGINT SIGTERM].each do |sig|
      Signal.trap sig do
        pids.each { |pid| Process.kill sig, pid }
        Process.waitall
        puts "ERROR: TFW received and forwarded #{sig} to terraform"
        exit 2
      end
    end
  end

  def load_module(stack, &block)
    t = TFW::Module.new do
      instance_eval(&block) if block_given?
    end

    mstack = t.instance_variable_get '@stack'
    mname = t.instance_variable_get '@name'
    mpath = "./modules/#{mname}"

    FileUtils.mkdir_p "#{WORKSPACE}/#{mpath}"

    stack_file = "#{WORKSPACE}/#{mpath}/stack.tf"
    write_stack_file stack_file, mstack

    stack.tfmodule mname do
      source mpath
    end
  end

  def write_stack_file(stack_file, stack)
    [stack_file, "#{stack_file}.json"].each { |f| FileUtils.rm_f f }

    if as_json?
      stack_file = "#{stack_file}.json"
      File.write stack_file, pretty_json(AwsSgWorkaround.fix(stack.to_json))
    else
      File.write stack_file, stack
    end
  end

  def configure_methods_using_stack(stack)
    silent_block do
      # This will trigger warnings as we are redefining methods
      %w[provider variable locals tfmodule datasource resource output terraform].each do |name|
        TOPLEVEL_BINDING.eval('self').define_singleton_method name do |*args, &block|
          stack.method(name).call(*args, &block)
        end
      end
    end
  end

  def configure_input_method(input)
    silent_block do
      # This will trigger warnings as we are redefining methods
      TOPLEVEL_BINDING.eval('self').define_singleton_method('tfw_module_input') { input }
    end
  end

  def pretty_json(json)
    JSON.pretty_generate JSON.parse(json)
  end
end

def silent_block
  stderr, stdout = [STDERR, STDOUT].map(&:clone)
  [STDERR, STDOUT].each { |e| e.reopen File.new('/dev/null', 'w') }
  begin
    yield
  ensure
    { STDERR => stderr, STDOUT => stdout }.each { |k, v| k.reopen v }
  end
end

def tfw_load_module(&block)
  TFW.load_module(self, &block)
end
