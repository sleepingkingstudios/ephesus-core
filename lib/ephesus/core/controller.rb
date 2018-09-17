# frozen_string_literal: true

require 'securerandom'

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'cuprum/command_factory'

module Ephesus::Core
  # Abstract base class for Ephesus controllers. Define actions that permit a
  # user to interact with the game state.
  class Controller < Cuprum::CommandFactory
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    class << self
      def action(name, action_class)
        command(name) do |*args, &block|
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

    alias action? command?
    alias actions commands

    def execute_action(action_name, *args)
      unless action?(action_name)
        raise ArgumentError, "invalid action name #{action_name.inspect}"
      end

      send(action_name).call(*args)
    end
  end
end
