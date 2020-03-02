# frozen_string_literal: true

module TFW
  # Singleton class to keep the stack
  class State
    include Singleton

    def initialize
      @stack = TFDSL::Stack.new
    end

    def stack(&block)
      @stack.instance_eval(&block) if block_given?
      @stack
    end

    def reset
      @stack = TFDSL::Stack.new
    end
  end
end
