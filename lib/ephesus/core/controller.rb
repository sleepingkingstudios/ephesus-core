# frozen_string_literal: true

require 'cuprum/command_factory'

require 'ephesus/core/commands/invalid_command_result'
require 'ephesus/core/commands/unavailable_command_result'

module Ephesus::Core
  # Abstract base class for Ephesus controllers. Define commands that permit a
  # user to interact with the game state.
  class Controller < Cuprum::CommandFactory
    class << self
      def command(name, command_class, **metadata)
        unless command_class?(command_class)
          raise ArgumentError,
            'expected command class to be a subclass of ' \
            "Ephesus::Core::Command, but was #{command_class.inspect}"
        end

        metadata = metadata.merge(
          properties: command_class.properties,
          signature:  command_class.signature
        )

        super(name, command_class, metadata)
      end

      private :command_class # rubocop:disable Style/AccessModifierDeclarations

      private

      def command_class?(value)
        return false unless value.is_a?(Class)

        value < Ephesus::Core::Command
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

        hsh[command_name] = definition.fetch(:properties, {})
      end
    end

    def execute_command(command_name, *args)
      definition = definition_for(command_name)
      arguments, keywords = split_arguments(args)

      wrap_result(command_name, arguments, keywords) do
        handle_invalid_command(definition) ||
          handle_unavailable_command(definition) ||
          handle_invalid_arguments(definition, arguments, keywords) ||
          send(command_name).call(*args)
      end
    end

    private

    def available?(defn)
      return false unless defn

      return false if defn.key?(:if)     && !defn[:if].call(state)
      return false if defn.key?(:unless) && defn[:unless].call(state)

      true
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

    def split_arguments(arguments)
      return [arguments, {}] unless arguments.last.is_a?(Hash)

      [arguments[0...-1], arguments.last]
    end

    def wrap_result(command_name, arguments, keywords)
      yield.tap do |result|
        result.command_name = command_name
        result.arguments    = arguments
        result.keywords     = keywords
      end
    end
  end
end
