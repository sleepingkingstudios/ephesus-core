# frozen_string_literal: true

require 'ephesus/core/events'

require 'sleeping_king_studios/tools/toolbox/mixin'

module Ephesus::Core::Events
  # Helper module for handling event listeners. Provides a DSL for defining
  # event listeners directly from the class definition, either with a block or
  # the name of an instance method.
  module EventHandlers
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods for defining event listeners from the class definition.
    module ClassMethods
      def handle_event(event_type, method_name = nil, &block)
        defined_event_handlers <<
          if method_name
            [event_type, method_name]
          else
            [event_type, block]
          end
      end

      protected

      def event_handlers
        parent_event_handlers + defined_event_handlers
      end

      private

      def defined_event_handlers
        @defined_event_handlers ||= []
      end

      def parent_event_handlers
        return [] unless superclass.methods.include?(:event_handlers)

        superclass.event_handlers
      end
    end

    def initialize(*args, event_dispatcher:, &block)
      super(*args, &block)

      @event_dispatcher = event_dispatcher

      add_event_handlers
    end

    attr_reader :event_dispatcher

    def add_event_listener(event_type, method_name = nil, &block)
      block = method_lambda(method_name) if method_name

      event_dispatcher.add_event_listener(event_type, &block)
    end

    private

    def add_event_handlers
      handlers = self.class.send(:event_handlers)

      handlers.each do |event_type, handler|
        if handler.is_a?(Proc)
          add_event_listener(event_type, &instance_exec_lambda(handler))
        else
          add_event_listener(event_type, handler)
        end
      end
    end

    def instance_exec_lambda(proc)
      if proc.arity.zero?
        -> { instance_exec(&proc) }
      else
        ->(event) { instance_exec(event, &proc) }
      end
    end

    def method_lambda(method_name)
      lambda do |event|
        defn = method(method_name)

        if defn && !defn.arity.zero?
          send(method_name, event)
        else
          send(method_name)
        end
      end
    end
  end
end
