# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'ephesus/core/event'
require 'ephesus/core/events'

module Ephesus::Core::Events
  # Mixin for creating a registry of events, e.g. for registering events related
  # to a given controller or context. Registered events have a consistent naming
  # structure and can define parent events and data keys.
  module EventRegistry
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods for creating a registry of events.
    module ClassMethods
      def event(event_name, *event_keys)
        event_type = generate_event_type(event_name)
        klass_name = tools.string.chain(event_name, :underscore, :camelize)
        const_name = tools.string.underscore(event_name).upcase

        const_set(const_name, event_type)

        define_event_class(
          keys: event_keys,
          name: klass_name,
          type: event_type
        )

        klass_name.intern
      end

      private

      def define_event_class(keys:, name:, type:)
        parent_class   = keys.shift if keys.first.is_a?(Class)
        parent_class ||= Ephesus::Core::Event
        event_class    = parent_class.subclass(type, *keys)

        event_class.const_set(:TYPE, type)

        const_set(name, event_class)
      end

      def generate_event_type(event_name)
        name
          .split('::')
          .push(event_name)
          .map { |str| tools.string.underscore(str) }
          .join('.')
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end
  end
end
