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
            event_dispatcher: event_dispatcher,
            repository:       repository,
            &block
          )
        end
      end
      # rubocop:enable Metrics/MethodLength
    end

    def initialize(state, event_dispatcher:, repository: nil)
      @state            = state
      @event_dispatcher = event_dispatcher
      @repository       = repository
    end

    attr_reader :event_dispatcher

    attr_reader :repository

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
      available  = available?(definition)

      if definition.nil? || (!available && definition[:secret])
        return Ephesus::Core::Actions::InvalidActionResult.new(action_name)
      end

      unless available
        return Ephesus::Core::Actions::UnavailableActionResult.new(action_name)
      end

      send(action_name).call(*args)
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
  end
end
