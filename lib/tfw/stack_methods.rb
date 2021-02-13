# frozen_string_literal: true

module TFW
  # Dynamically create stack methods
  module CreateStackMethods
    def create_stack_methods
      stack = TFW::State.instance.stack
      %w[provider variable locals tfmodule datasource resource output terraform].each do |name|
        define_method(name) { |*args, &block| stack.method(name).call(*args, &block) }
      end
    end
  end

  # This class carries stack methods, use it through inheritance class SomeClass < StackMethods
  class StackMethods
    extend CreateStackMethods
    create_stack_methods
  end
end
