# frozen_string_literal: true

module TFW
  # This is the Module for TFW
  class Module
    extend Setters
    make_setter :name, :source, :input

    def initialize(&block)
      instance_eval(&block) if block_given?

      %i[name source].each do |e|
        raise "#{e} must be specified for module" if instance_variable_get("@#{e}").nil?
      end

      @stack = get_stack_for_dir @source, @input
    end

    def get_stack_for_dir(dir, input = nil)
      files = Dir.glob "#{dir}/*.rb"
      stack = TFDSL.stack do
        instance_variable_set '@_input', input
        files.sort.each { |f| instance_eval File.read(f), f }
        # files.sort.each { |f| load f }
      end
      stack
    end
  end
end
