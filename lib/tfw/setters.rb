# frozen_string_literal: true

module TFW
  # Module to create dynamic setters
  module Setters
    def make_setter(*names)
      names.each do |name|
        define_method(name) do |val|
          instance_variable_set("@#{name}", val)
          return self
        end
      end
    end
  end
end
