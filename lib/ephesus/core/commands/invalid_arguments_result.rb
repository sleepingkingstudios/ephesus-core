# frozen_string_literal: true

require 'ephesus/core/commands'
require 'ephesus/core/commands/result'

module Ephesus::Core::Commands
  # Predefined result, to be returned when a command is executed with invalid
  # arguments.
  class InvalidArgumentsResult < Ephesus::Core::Commands::Result
    def initialize(command_name = nil, **keywords)
      super(nil, command_name: command_name, **keywords)

      errors.add :invalid_arguments
    end
  end
end
