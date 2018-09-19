# frozen_string_literal: true

require 'ephesus/core/utils/immutable'

module Ephesus::Core
  # Base class for Ephesus applications. An application has a single state, and
  # is referenced by one or many sessions.
  class Application
    def initialize(event_dispatcher:, repository: nil)
      @event_dispatcher = event_dispatcher
      @repository       = repository
      @state            =
        Ephesus::Core::Utils::Immutable.from_hash(initial_state)

      initialize_reducers!
    end

    attr_reader :event_dispatcher

    attr_reader :repository

    attr_reader :state

    def add_event_listener(event_type, method_name = nil, &block)
      if block_given?
        add_block_listener(event_type, &block)
      elsif method_name
        add_method_listener(event_type, method_name)
      else
        raise ArgumentError, 'listener must be a method name or a block'
      end
    end

    protected

    attr_writer :state

    private

    def add_block_listener(event_type, &block)
      if block.arity.zero?
        event_dispatcher.add_event_listener(event_type) do
          instance_exec(&block)
        end
      else
        event_dispatcher.add_event_listener(event_type) do |event|
          instance_exec(event, &block)
        end
      end
    end

    def add_method_listener(event_type, method_name)
      definition = method(method_name)

      if definition.arity.zero?
        event_dispatcher.add_event_listener(event_type) do
          send(method_name)
        end
      else
        event_dispatcher.add_event_listener(event_type) do |event|
          send(method_name, event)
        end
      end
    end

    def build_reducer(definition)
      if definition.is_a?(Proc)
        return lambda do |event|
          self.state = instance_exec(state, event, &definition)
        end
      end

      ->(event) { self.state = send(definition, state, event) }
    end

    def initial_state
      {}
    end

    def initialize_reducers!
      reducers.each do |reducer|
        reducer.listeners.each do |event_type, definition|
          add_event_listener(event_type, &build_reducer(definition))
        end
      end
    end

    def reducers
      self.class.ancestors.select { |mod| mod.is_a?(Ephesus::Core::Reducer) }
    end
  end
end
