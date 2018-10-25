# frozen_string_literal: true

require 'cuprum/command_factory'

require 'ephesus/core/actions/invalid_action_result'
require 'ephesus/core/actions/unavailable_action_result'

module Ephesus::Core
  # Abstract base class for Ephesus controllers. Define actions that permit a
  # user to interact with the game state.
  class Controller < Cuprum::CommandFactory
    class << self
      # rubocop:disable Metrics/MethodLength
      def action(name, action_class, **metadata)
        metadata = metadata.merge(
          action:     true,
          properties: action_class.properties,
          signature:  action_class.signature
        )

        command(name, metadata) do |*args, &block|
          action_class.new(
            state,
            *args,
            dispatcher: dispatcher,
            **options,
            &block
          )
        end
      end
      # rubocop:enable Metrics/MethodLength
    end

    def initialize(state, dispatcher:, **options)
      @state      = state
      @dispatcher = dispatcher
      @options    = options
    end

    attr_reader :dispatcher

    attr_reader :options

    attr_reader :state

    def action?(action_name)
      action_name = normalize_command_name(action_name)

      actions.include?(action_name)
    end

    def actions
      self
        .class
        .send(:command_definitions)
        .select { |_, hsh| hsh.fetch(:action, false) }
        .keys
    end

    def available_actions
      self
        .class
        .send(:command_definitions)
        .each
        .with_object({}) \
      do |(action_name, definition), hsh|
        next unless definition.fetch(:action, false)
        next unless available?(definition)

        hsh[action_name] = definition.fetch(:properties, {})
      end
    end

    def execute_action(action_name, *args)
      definition = definition_for(action_name)
      arguments, keywords = split_arguments(args)

      wrap_result(action_name, arguments, keywords) do
        handle_invalid_action(definition) ||
          handle_unavailable_action(definition) ||
          handle_invalid_arguments(definition, arguments, keywords) ||
          send(action_name).call(*args)
      end
    end

    private

    def available?(defn)
      return false unless defn

      return false if defn.key?(:if)     && !defn[:if].call(state)
      return false if defn.key?(:unless) && defn[:unless].call(state)

      true
    end

    def definition_for(action_name)
      self.class.send(:command_definitions)[action_name]
    end

    def handle_invalid_action(definition)
      return nil if definition

      Ephesus::Core::Actions::InvalidActionResult.new
    end

    def handle_invalid_arguments(definition, arguments, keywords)
      signature = definition[:signature]
      success, error_result = signature.match(*arguments, **keywords)

      success ? nil : error_result
    end

    def handle_unavailable_action(definition)
      return nil if available?(definition)

      if definition[:secret]
        return Ephesus::Core::Actions::InvalidActionResult.new
      end

      Ephesus::Core::Actions::UnavailableActionResult.new
    end

    def split_arguments(arguments)
      return [arguments, {}] unless arguments.last.is_a?(Hash)

      [arguments[0...-1], arguments.last]
    end

    def wrap_result(action_name, arguments, keywords)
      yield.tap do |result|
        result.action_name = action_name
        result.arguments   = arguments
        result.keywords    = keywords
      end
    end
  end
end
