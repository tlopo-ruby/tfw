# frozen_string_literal: true

require 'tfw/version'
require 'tfdsl'
require 'json'
require 'singleton'
require_relative 'tfw/state'

%w[provider variable locals tfmodule datsource resource output terraform].each do |name|
  define_method name do |*args, &block|
    State.instance.stack.method(name).call(*args, &block)
  end
end

# TFW is a Terraform Wrapper which uses terraform DSL for Ruby
module TFW
  module_function

  LIB_DIR = "#{__dir__}/tfw/"

  require "#{LIB_DIR}/setters"
  require "#{LIB_DIR}/module"

  WORKSPACE = './.tfw'
  FileUtils.mkdir_p WORKSPACE

  def as_json?
    !ENV['TFW_AS_JSON'].nil?
  end

  def get_stack_for_dir(dir, input = nil)
    files = Dir.glob "#{dir}/*.rb"
    State.instance.stack do
      instance_variable_set '@_input', input
      files.sort.each { |f| load f }
    end
    State.instance.stack
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
      File.write stack_file, pretty_json(stack.to_json)
    else
      File.write stack_file, stack
    end
  end

  def pretty_json(json)
    JSON.pretty_generate JSON.parse(json)
  end
end

def tfw_load_module(&block)
  TFW.load_module(self, &block)
end
