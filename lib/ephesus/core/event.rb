# frozen_string_literal: true

require 'ephesus/core'

require 'ephesus/core/events/event_builder'

module Ephesus::Core
  # Object representing an application event, with a set type and optional data.
  # Used for communication between Ephesus components.
  class Event
    class << self
      def keys
        Set.new
      end

      def subclass(subclass_type, *subclass_keys)
        Ephesus::Core::Events::EventBuilder
          .new(self)
          .build(subclass_type, subclass_keys)
      end
    end

    def initialize(event_type, **data)
      @event_types = Array(event_type)
      @event_type  = @event_types.last
      @data        = data
    end

    def <(other)
      raise ArgumentError, 'comparison of Event with nil failed' if other.nil?

      unless other.is_a?(String) || other.is_a?(Symbol)
        raise ArgumentError, "comparison of Event with #{other.class} failed"
      end

      event_types[0...-1].include?(other)
    end

    def <=(other)
      raise ArgumentError, 'comparison of Event with nil failed' if other.nil?

      unless other.is_a?(String) || other.is_a?(Symbol)
        raise ArgumentError, "comparison of Event with #{other.class} failed"
      end

      event_types.include?(other)
    end

    def ==(other)
      return true if super

      return match_event?(other) if other.is_a?(Ephesus::Core::Event)

      if other.is_a?(String) || other.is_a?(Symbol)
        return match_event_type?(other.to_s)
      end

      false
    end

    attr_reader :data

    attr_reader :event_type

    attr_reader :event_types

    private

    def match_event?(event)
      event_types == event.event_types && data == event.data
    end

    def match_event_type?(event_type)
      event_types.include?(event_type)
    end
  end
end
