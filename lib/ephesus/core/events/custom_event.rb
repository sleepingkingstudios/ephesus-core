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

        hsh  = tools.hash.convert_keys_to_symbols(hsh)
        data = hsh[:data] || {}

        guard_event_types(hsh)

        new(data)
      end

      private

      def default_data
        {}
      end

      def guard_event_types(hsh)
        types = super

        return if types.empty?

        return if event_types == types

        return if types.count == 1 && event_types.last == types.last

        raise ArgumentError,
          "expected event types to be #{event_types.inspect}, but were " \
          "#{Array(types)}"
      end
    end

    def initialize(**data)
      event_types = self.class.send(:event_types)
      event_data  = self.class.send(:default_data).merge(data)

      super(*event_types, event_data)
    end
  end
end
