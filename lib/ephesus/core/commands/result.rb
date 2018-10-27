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

      @command_name = command_name
      @arguments    = arguments
      @keywords     = keywords
    end

    attr_accessor :command_name

    attr_accessor :arguments

    attr_accessor :keywords

    private

    def build_errors
      Bronze::Errors.new
    end
  end
end
