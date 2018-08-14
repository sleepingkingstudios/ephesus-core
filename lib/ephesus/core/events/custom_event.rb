# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'ephesus/core/events'

module Ephesus::Core::Events
  # Constructor mixin for custom Ephesus events with a defined event_type.
  module CustomEvent
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods for a custom Ephesus event.
    module ClassMethods
      def from_hash(hsh)
        unless hsh.respond_to?(:to_hash)
          raise ArgumentError, 'argument must be a Hash'
        end

        hsh   = tools.hash.convert_keys_to_symbols(hsh)
        types = Array(guard_event_types(hsh))
        data  = hsh[:data] || {}
        event = new(data)

        set_event_types(event, types) if event_types.empty?

        event
      end

      private

      def default_data
        {}
      end

      def event_types
        []
      end

      def guard_event_types(hsh)
        types = super

        return types if event_types.empty?

        return if types.is_a?(Array) && event_types == types

        return if !types.is_a?(Array) && event_types.include?(types)

        raise ArgumentError,
          "expected event types to be #{event_types.inspect}, but were " \
          "#{Array(types)}"
      end

      def set_event_types(event, event_types)
        event.instance_variable_set(:@event_type,  event_types.last)
        event.instance_variable_set(:@event_types, event_types)

        event
      end
    end

    def initialize(**data)
      super(nil, self.class.send(:default_data).merge(data))
    end
  end
end
