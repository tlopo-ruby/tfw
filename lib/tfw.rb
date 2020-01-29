# frozen_string_literal: true

require 'tfw/version'
require 'tfdsl'
require 'json'

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
    stack = TFDSL.stack do
      instance_variable_set '@_input', input
      files.sort.each { |f| instance_eval File.read(f), f }
    end
    stack
  end

  def cli(args)
    stack = TFW.get_stack_for_dir '.'

    stack_file = "#{WORKSPACE}/stack.tf"
    write_stack_file stack_file, stack

    old_dir = Dir.pwd
    Dir.chdir WORKSPACE

    cmd = "terraform #{args.join ' '}"
    Process.wait(fork { exec cmd })
    Dir.chdir old_dir
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
