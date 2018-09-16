# frozen_string_literal: true

require 'ephesus/core/controllers/controller_builder'
require 'ephesus/core/events/controller_events'
require 'ephesus/core/utils/immutable'

module Ephesus::Core
  # Base class for Ephesus applications, which manage input controllers and
  # contexts.
  class Application
    def initialize(event_dispatcher:, repository: nil)
      @controllers      = []
      @event_dispatcher = event_dispatcher
      @repository       = repository
      @state            =
        Ephesus::Core::Utils::Immutable.from_hash(initial_state)
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

    def current_controller
      @controllers.last
    end

    def execute_action(action_name, *args)
      raise 'application does not have a controller' unless current_controller

      current_controller.execute_action(action_name, *args)
    end

    def start_controller(controller, **keywords)
      controller = build_controller(controller)

      controllers << controller.start(keywords)

      controller
    end

    def stop_controller(identifier)
      controller = find_controller_by_identifier(identifier)

      unless controller
        raise ArgumentError, "invalid identifier #{identifier.inspect}"
      end

      controllers.delete(controller)

      controller.stop
    end

    private

    attr_reader :controllers

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

    def build_controller(controller)
      Ephesus::Core::Controllers::ControllerBuilder
        .new(event_dispatcher: event_dispatcher, repository: repository)
        .build(controller)
    end

    def find_controller_by_identifier(identifier)
      controllers.find { |controller| controller.identifier == identifier }
    end

    def initial_state
      {}
    end
  end
end
