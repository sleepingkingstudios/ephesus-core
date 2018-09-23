# frozen_string_literal: true

require 'cuprum/command_factory'

module Ephesus::Core
  # Abstract base class for Ephesus controllers. Define actions that permit a
  # user to interact with the game state.
  class Controller < Cuprum::CommandFactory
    class << self
      def action(name, action_class)
        command(name, action: true) do |*args, &block|
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
      actions.each.with_object({}) do |action_name, hsh|
        hsh[action_name] = {}
      end
    end

    def execute_action(action_name, *args)
      unless action?(action_name)
        raise ArgumentError, "invalid action name #{action_name.inspect}"
      end

      send(action_name).call(*args)
    end
  end
end
