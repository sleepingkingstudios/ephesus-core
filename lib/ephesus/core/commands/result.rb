# frozen_string_literal: true

require 'bronze/errors'
require 'cuprum/result'

require 'ephesus/core/commands'

module Ephesus::Core::Commands
  # Custom result subclass representing the result of calling an Ephesus
  # command. Includes additional metadata including the name of the called
  # command and the arguments and keywords used.
  class Result < Cuprum::Result
    def initialize(
      value = nil,
      command_name: nil,
      arguments:    [],
      errors:       nil,
      keywords:     {}
    )
      super(value, errors: errors)

      @data = {
        arguments:    arguments,
        command_name: command_name,
        keywords:     keywords
      }
    end

    %i[
      arguments
      command_name
      keywords
    ].each do |method_name|
      define_method(method_name) { @data[method_name] }

      define_method(:"#{method_name}=") { |value| @data[method_name] = value }
    end

    attr_reader :data

    private

    def build_errors
      Bronze::Errors.new
    end
  end
end
