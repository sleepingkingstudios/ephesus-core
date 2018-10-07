# frozen_string_literal: true

require 'cuprum/command_factory'

require 'ephesus/core/actions/invalid_action_result'

module Ephesus::Core
  # Abstract base class for Ephesus controllers. Define actions that permit a
  # user to interact with the game state.
  class Controller < Cuprum::CommandFactory
    class << self
      def action(name, action_class, **metadata)
        command(name, metadata.merge(action: true)) do |*args, &block|
          action_class.new(
            state,
            *args,
            event_dispatcher: event_dispatcher,
            repository:       repository,
            &block
          )
        end
      end
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

        hsh[action_name] = {}
      end
    end

    def execute_action(action_name, *args)
      definition = definition_for(action_name)
      available  = available?(definition)

      if definition.nil? || (!available && definition[:secret])
        return Ephesus::Core::Actions::InvalidActionResult.new(action_name)
      end

      return unavailable_action_result(action_name, args) unless available

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

    def unavailable_action_result(action_name, args)
      errors = Bronze::Errors.new

      errors.add(
        :unavailable_action,
        action_name: action_name,
        arguments:   args
      )

      Cuprum::Result.new(nil, errors: errors)
    end
  end
end
