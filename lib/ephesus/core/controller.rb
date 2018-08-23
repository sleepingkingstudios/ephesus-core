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

    def initialize(event_dispatcher:)
      @event_dispatcher = event_dispatcher
    end

    attr_reader :context

    attr_reader :event_dispatcher

    delegate :dispatch_event, to: :event_dispatcher

    alias action? command?
    alias actions commands

    def execute_action(action_name, *args)
      raise 'controller does not have a context' if context.nil?

      unless action?(action_name)
        raise ArgumentError, "invalid action name #{action_name.inspect}"
      end

      send(action_name).call(*args)
    end

    def start(**keywords)
      raise 'controller already has a context' unless context.nil?

      @context = build_context(keywords)

      self
    end

    private

    def build_context(**_keywords)
      raise NotImplementedError,
        'override #build_context in Controller subclasses'
    end
  end
end
