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

      private

      def default_data
        {}
      end
    end

    def initialize(event_type, **data)
      @event_type = event_type
      @data       = self.class.send(:default_data).merge(data)
    end

    attr_reader :data

    attr_reader :event_type
  end
end
