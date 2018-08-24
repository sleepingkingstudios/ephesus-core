# frozen_string_literal: true

require 'ephesus/core/controllers'

module Ephesus::Core::Controllers
  # Builder class for instantiating controller instances from a class or class
  # name.
  class ControllerBuilder
    def initialize(event_dispatcher:)
      @event_dispatcher = event_dispatcher
    end

    attr_reader :event_dispatcher

    def build(controller)
      controller_class = resolve_controller(controller)

      controller_class.new(event_dispatcher: event_dispatcher)
    end

    private

    def controller_class?(controller)
      controller.is_a?(Class) && controller < Ephesus::Core::Controller
    end

    def guard_controller_class!(controller_class)
      return unless controller_class

      return if controller_class?(controller_class)

      raise ArgumentError,
        "expected #{controller_class} to be a subclass of " \
        'Ephesus::Core::Controller'
    end

    def guard_controller_name!(controller_name)
      return if controller_name.is_a?(String) || controller_name.is_a?(Symbol)

      raise ArgumentError,
        'expected controller to be a controller class or qualified name, ' \
        "but was #{controller_name.inspect}"
    end

    def resolve_controller(controller)
      return controller if controller_class?(controller)

      guard_controller_name!(controller)

      controller_name  = controller.to_s
      controller_class = Object.const_get(controller_name)

      guard_controller_class!(controller_class)

      controller_class
    end
  end
end
