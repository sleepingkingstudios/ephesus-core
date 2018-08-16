# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'cuprum/command_factory'

require 'ephesus/core'

module Ephesus::Core
  # Abstract base class for Ephesus controllers. Define actions that permit a
  # user to interact with the game state.
  class Controller < Cuprum::CommandFactory
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    class << self
      def action(name, action_class)
        command(name) do |*args, &block|
          action_class.new(
            context,
            *args,
            event_dispatcher: event_dispatcher,
            &block
          )
        end
      end
    end

    def initialize(context, event_dispatcher:)
      @context          = context
      @event_dispatcher = event_dispatcher
    end

    attr_reader :context

    attr_reader :event_dispatcher

    delegate :dispatch_event, to: :event_dispatcher

    alias action? command?
    alias actions commands
  end
end
