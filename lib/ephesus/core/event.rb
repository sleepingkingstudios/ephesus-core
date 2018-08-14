# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

require 'ephesus/core'

require 'ephesus/core/events/event_builder'

module Ephesus::Core
  # Object representing an application event, with a set type and optional data.
  # Used for communication between Ephesus components.
  class Event
    class << self
      def from_hash(hsh)
        unless hsh.respond_to?(:to_hash)
          raise ArgumentError, 'argument must be a Hash'
        end

        hsh   = tools.hash.convert_keys_to_symbols(hsh)
        types = guard_event_types(hsh)
        data  = hsh[:data] || {}

        new(types, data)
      end

      def keys
        Set.new
      end

      def subclass(subclass_type, *subclass_keys)
        Ephesus::Core::Events::EventBuilder
          .new(self)
          .build(subclass_type, subclass_keys)
      end

      private

      def guard_event_types(hsh)
        unless hsh.key?(:event_types)
          raise ArgumentError, 'missing key :event_types'
        end

        types = hsh[:event_types]

        raise ArgumentError, "event_types can't be nil" if types.nil?

        types = types.compact if types.respond_to?(:compact)

        if types.respond_to?(:empty?) && types.empty?
          raise ArgumentError, "event_types can't be empty"
        end

        types
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end

    def initialize(event_type, **data)
      @event_types = Array(event_type)
      @event_type  = @event_types.last
      @data        = data
    end

    attr_reader :data

    attr_reader :event_type

    attr_reader :event_types

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

    def to_h
      {
        event_types: event_types.dup,
        data:        data
      }
    end

    private

    def match_event?(event)
      event_types == event.event_types && data == event.data
    end

    def match_event_type?(event_type)
      event_types.include?(event_type)
    end
  end
end
