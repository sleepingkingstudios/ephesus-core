# frozen_string_literal: true

require 'forwardable'

require 'ephesus/core/event_dispatcher'
require 'ephesus/core/immutable_store'
require 'ephesus/core/utils/immutable'

module Ephesus::Core
  # Base class for Ephesus applications. An application has a single state, and
  # is referenced by one or many sessions.
  class Application
    extend Forwardable

    def initialize(event_dispatcher: nil, repository: nil, state: nil)
      @event_dispatcher = event_dispatcher || Ephesus::Core::EventDispatcher.new
      @repository       = repository

      @store = build_store(state || initial_state)
    end

    def_delegator :@store, :state

    attr_reader :event_dispatcher

    attr_reader :repository

    attr_reader :store

    def add_event_listener(event_type, method_name = nil, &block)
      if block_given?
        add_block_listener(event_type, &block)
      elsif method_name
        add_method_listener(event_type, method_name)
      else
        raise ArgumentError, 'listener must be a method name or a block'
      end
    end

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

    def build_store(state)
      Ephesus::Core::ImmutableStore.new(state)
    end

    def initial_state
      nil
    end
  end
end
