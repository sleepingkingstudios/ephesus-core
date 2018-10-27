# frozen_string_literal: true

require 'ephesus/core/commands'
require 'ephesus/core/commands/result'

module Ephesus::Core::Commands
  # Predefined result, to be returned when an unavailable command is executed.
  class UnavailableCommandResult < Ephesus::Core::Commands::Result
    def initialize(command_name = nil, **keywords)
      super(nil, command_name: command_name, **keywords)

      errors.add :unavailable_command
    end
  end
end
