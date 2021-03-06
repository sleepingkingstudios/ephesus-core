# frozen_string_literal: true

require 'cuprum/command_factory'

require 'ephesus/core/commands/invalid_command_result'
require 'ephesus/core/commands/unavailable_command_result'

# rubocop:disable Metrics/ClassLength
module Ephesus::Core
  # Abstract base class for Ephesus controllers. Define commands that permit a
  # user to interact with the game state.
  class Controller < Cuprum::CommandFactory
    class << self
      def command(name, command_class, **metadata, &block)
        guard_command_class(command_class)

        metadata =
          merge_metadata(metadata, command_class: command_class, name: name)

        if block_given?
          super(name, metadata, &block)
        else
          super(name, command_class, metadata)
        end
      end

      private :command_class # rubocop:disable Style/AccessModifierDeclarations

      private

      def command_class?(value)
        return false unless value.is_a?(Class)

        value < Ephesus::Core::Command
      end

      def guard_command_class(command_class)
        return if command_class?(command_class)

        raise ArgumentError,
          'expected command class to be a subclass of ' \
          "Ephesus::Core::Command, but was #{command_class.inspect}"
      end

      def merge_aliases(command_name, aliases)
        [command_name, *aliases]
          .map { |str| tools.string.underscore(str).tr('_', ' ') }
          .uniq
          .sort
      end

      def merge_metadata(metadata, command_class:, name:)
        hsh = tools.hash.convert_keys_to_symbols(metadata)

        hsh.merge(
          aliases:    merge_aliases(name, metadata[:aliases]),
          properties: command_class.properties,
          signature:  command_class.signature
        )
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end

    def initialize(state, dispatcher:, **options)
      @state      = state
      @dispatcher = dispatcher
      @options    = options
    end

    attr_reader :dispatcher

    attr_reader :options

    attr_reader :state

    def available_commands
      self
        .class
        .send(:command_definitions)
        .each
        .with_object({}) \
      do |(command_name, definition), hsh|
        next unless available?(definition)

        hsh[command_name] =
          available_definition(definition, command_name: command_name)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def execute_command(command_name, *args)
      definition = definition_for(command_name)
      arguments, keywords = split_arguments(args)

      result = \
        handle_invalid_command(definition) ||
        handle_unavailable_command(definition) ||
        handle_invalid_arguments(definition, arguments, keywords) ||
        (command = send(command_name)).call(*args)

      update_result_data(
        result,
        arguments:     arguments,
        command_class: command&.class&.name,
        command_name:  command_name,
        controller:    self.class.name,
        keywords:      keywords
      )
    end
    # rubocop:enable Metrics/MethodLength

    private

    def available?(defn)
      return false unless defn

      return false if defn.key?(:if)     && !defn[:if].call(state)
      return false if defn.key?(:unless) && defn[:unless].call(state)

      true
    end

    def available_definition(defn, command_name:)
      hsh      =
        defn.fetch(:properties, {}).merge(aliases: defn.fetch(:aliases, []))
      examples = hsh.fetch(:examples, [])

      return hsh if examples.empty?

      hsh.merge(
        examples: interpolate_examples(examples, command_name: command_name)
      )
    end

    def build_command(command_class, *args, &block)
      super(
        command_class,
        state,
        *args,
        dispatcher: dispatcher,
        **options,
        &block
      )
    end

    def definition_for(command_name)
      self.class.send(:command_definitions)[command_name]
    end

    def handle_invalid_command(definition)
      return nil if definition

      Ephesus::Core::Commands::InvalidCommandResult.new
    end

    def handle_invalid_arguments(definition, arguments, keywords)
      signature = definition[:signature]
      success, error_result = signature.match(*arguments, **keywords)

      success ? nil : error_result
    end

    def handle_unavailable_command(definition)
      return nil if available?(definition)

      if definition[:secret]
        return Ephesus::Core::Commands::InvalidCommandResult.new
      end

      Ephesus::Core::Commands::UnavailableCommandResult.new
    end

    def interpolate_command(string, command_name:)
      command_name = command_name.to_s.tr('_', ' ')

      string.gsub('$COMMAND', command_name)
    end

    def interpolate_examples(examples, command_name:)
      examples.map do |hsh|
        hsh.merge(
          command: interpolate_command(
            hsh[:command],
            command_name: command_name
          )
        )
      end
    end

    def split_arguments(arguments)
      return [arguments, {}] unless arguments.last.is_a?(Hash)

      [arguments[0...-1], arguments.last]
    end

    def update_result_data(result, data)
      result.tap do
        data.each do |key, value|
          result.send(:"#{key}=", value)
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
