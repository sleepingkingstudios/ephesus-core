# frozen_string_literal: true

require 'ephesus/core/controllers/controller_builder'
require 'ephesus/core/events/controller_events'

module Ephesus::Core
  # Base class for Ephesus applications, which manage input controllers and
  # contexts.
  class Application
    def initialize(event_dispatcher:, repository: nil)
      @event_dispatcher = event_dispatcher
      @controllers      = []
      @repository       = repository

      add_event_listeners
    end

    attr_reader :event_dispatcher

    attr_reader :repository

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

    # rubocop:disable Metrics/MethodLength
    def add_event_listeners
      event_dispatcher.add_event_listener(
        Ephesus::Core::Events::ControllerEvents::START_CONTROLLER,
        &start_controller_handler
      )

      event_dispatcher.add_event_listener(
        Ephesus::Core::Events::ControllerEvents::STOP_CONTROLLER,
        &stop_controller_handler
      )

      event_dispatcher.add_event_listener(
        Ephesus::Core::Events::ControllerEvents::STOP_CURRENT_CONTROLLER,
        &stop_current_controller_handler
      )
    end
    # rubocop:enable Metrics/MethodLength

    def build_controller(controller)
      Ephesus::Core::Controllers::ControllerBuilder
        .new(event_dispatcher: event_dispatcher, repository: repository)
        .build(controller)
    end

    def find_controller_by_identifier(identifier)
      controllers.find { |controller| controller.identifier == identifier }
    end

    def start_controller_handler
      lambda do |event|
        start_controller(event.controller_type, event.controller_params || {})
      end
    end

    def stop_controller_handler
      ->(event) { stop_controller(event.identifier) }
    end

    def stop_current_controller_handler
      -> { stop_controller(current_controller.identifier) }
    end
  end
end
