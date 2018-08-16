# frozen_string_literal: true

require 'observer'

require 'ephesus/core/event_listener'

module Ephesus::Core
  # Dispatcher class that implements the Observer pattern, registering listeners
  # and dispatching events.
  class EventDispatcher
    include Observable

    def add_event_listener(event_type, &block)
      event_type = guard_event_type(event_type)
      listener   = Ephesus::Core::EventListener.new(event_type, &block)

      add_observer(listener)

      listener
    end

    def dispatch_event(event)
      unless event.is_a?(Ephesus::Core::Event)
        raise ArgumentError, 'expected event to be a Ephesus::Core::Event'
      end

      changed

      notify_observers(event)
    end

    def guard_event_type(event_type)
      return event_type if event_type.is_a?(String) || event_type.is_a?(Symbol)

      unless event_type.is_a?(Class)
        raise ArgumentError,
          'expected event_type to be an Event class, a String or a Symbol'
      end

      return event_type::TYPE if event_type.const_defined?(:TYPE)

      raise ArgumentError, 'expected event_type to define ::TYPE constant'
    end

    def remove_all_listeners
      delete_observers
    end

    def remove_event_listener(listener)
      unless listener.is_a?(Ephesus::Core::EventListener)
        raise ArgumentError,
          'expected listener to be a Ephesus::Core::EventListener'
      end

      delete_observer(listener)
    end
  end
end
