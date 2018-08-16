# frozen_string_literal: true

require 'ephesus/core/event'

module Ephesus::Core
  # Utility class that handles event updates from an Observable dispatcher,
  # ignoring events that do not match its configured event type.
  class EventListener
    def initialize(event_type, &listener)
      @event_type = event_type
      @listener   = listener
    end

    attr_reader :event_type

    def update(event)
      unless event.is_a?(Ephesus::Core::Event)
        raise ArgumentError, 'expected event to be a Ephesus::Core::Event'
      end

      return unless event <= event_type

      @listener.arity.zero? ? @listener.call : @listener.call(event)
    end
  end
end
