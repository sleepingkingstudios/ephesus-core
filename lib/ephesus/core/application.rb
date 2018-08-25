# frozen_string_literal: true

require 'ephesus/core/controllers/controller_builder'

module Ephesus::Core
  # Base class for Ephesus applications, which manage input controllers and
  # contexts.
  class Application
    def initialize(event_dispatcher:)
      @event_dispatcher = event_dispatcher
      @controllers      = []
    end

    attr_reader :event_dispatcher

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

    def build_controller(controller)
      Ephesus::Core::Controllers::ControllerBuilder
        .new(event_dispatcher: event_dispatcher)
        .build(controller)
    end

    def find_controller_by_identifier(identifier)
      controllers.find { |controller| controller.identifier == identifier }
    end
  end
end
