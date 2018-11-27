# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/core/commands/built_in'

module Ephesus::Core::Commands::BuiltIn
  # Predefined command that lists the currently available commands, sorted by
  # command and including the command description, if any.
  class ListCommands < Ephesus::Core::Command
    description 'List the commands that are currently available.'

    def initialize(available_commands)
      @available_commands = available_commands
    end

    attr_reader :available_commands

    private

    def command_descriptions
      available_commands.map do |key, hsh|
        [
          key.to_s.tr('_', ' '),
          hsh&.fetch(:description, nil)
        ]
      end
    end

    def process
      command_descriptions.sort_by(&:first)
    end
  end
end
