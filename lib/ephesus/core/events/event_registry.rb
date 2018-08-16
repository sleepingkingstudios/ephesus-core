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
        event_type     = generate_event_type(event_name)
        parent_class   = event_keys.shift if event_keys.first.is_a?(Class)
        parent_class ||= Ephesus::Core::Event
        event_class    = parent_class.subclass(event_type, *event_keys)
        const_name     = tools.string.camelize(event_name)

        event_class.const_set(:TYPE, event_type)

        const_set(const_name, event_class)

        const_name.intern
      end

      private

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
