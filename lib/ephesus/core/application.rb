# frozen_string_literal: true

require 'ephesus/core/controllers/controller_builder'
require 'ephesus/core/events/controller_events'
require 'ephesus/core/events/event_handlers'
require 'ephesus/core/utils/immutable'

module Ephesus::Core
  # Base class for Ephesus applications, which manage input controllers and
  # contexts.
  class Application
    include Ephesus::Core::Events::EventHandlers

    handle_event Ephesus::Core::Events::ControllerEvents::START_CONTROLLER,
      :start_controller_handler

    handle_event Ephesus::Core::Events::ControllerEvents::STOP_ALL_CONTROLLERS,
      :stop_all_controllers_handler

    handle_event Ephesus::Core::Events::ControllerEvents::STOP_CONTROLLER,
      :stop_controller_handler

    handle_event \
      Ephesus::Core::Events::ControllerEvents::STOP_CURRENT_CONTROLLER,
      :stop_current_controller_handler

    def initialize(event_dispatcher:, repository: nil)
      super(event_dispatcher: event_dispatcher)

      @controllers = []
      @repository  = repository
      @state       = Ephesus::Core::Utils::Immutable::from_hash(initial_state)
    end

    attr_reader :event_dispatcher

    attr_reader :repository

    attr_reader :state

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
        .new(event_dispatcher: event_dispatcher, repository: repository)
        .build(controller)
    end

    def find_controller_by_identifier(identifier)
      controllers.find { |controller| controller.identifier == identifier }
    end

    def initial_state
      {}
    end

    def start_controller_handler(event)
      start_controller(event.controller_type, event.controller_params || {})
    end

    def stop_all_controllers_handler
      controllers.reverse_each do |controller|
        stop_controller(controller.identifier)
      end
    end

    def stop_controller_handler(event)
      stop_controller(event.identifier)
    end

    def stop_current_controller_handler
      stop_controller(current_controller.identifier)
    end
  end
end
