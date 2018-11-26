# frozen_string_literal: true

require 'bronze/errors'
require 'cuprum/result'

require 'ephesus/core/commands'

module Ephesus::Core::Commands
  # Custom result subclass representing the result of calling an Ephesus
  # command. Includes additional metadata including the name of the called
  # command and the arguments and keywords used.
  class Result < Cuprum::Result
    def initialize(value = nil, errors: nil, **data)
      super(value, errors: errors)

      @data = default_data.merge(data)
    end

    %i[
      arguments
      command_class
      command_name
      controller
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

    def default_data
      {
        arguments:     [],
        command_class: nil,
        command_name:  nil,
        controller:    nil,
        keywords:      {}
      }
    end
  end
end
