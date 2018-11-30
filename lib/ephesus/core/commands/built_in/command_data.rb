# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/core/commands/built_in'

module Ephesus::Core::Commands::BuiltIn
  # Predefined command that returns the properties of the specified command.
  class CommandData < Ephesus::Core::Command
    COMMAND_NOT_FOUND_ERROR =
      'ephesus.core.commands.command_data.command_not_found'

    description 'Provides information about the requested command.'

    argument :command,
      description: 'The name of the command to query.',
      required:    true

    def initialize(available_commands)
      @available_commands = available_commands
    end

    attr_reader :available_commands

    private

    def matching_command(command_name)
      available_commands
        .values
        .find { |defn| defn[:aliases].include?(command_name) }
    end

    def normalize_command_name(command)
      return '' if command.nil?

      tools.string.underscore(command).tr('_', ' ')
    end

    def process(command)
      command_name = normalize_command_name(command)
      definition   = matching_command(command_name)

      return definition.merge(command_name: command_name) if definition

      result.errors.add(COMMAND_NOT_FOUND_ERROR, command: command)

      nil
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
