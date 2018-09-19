# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'ephesus/core'

module Ephesus::Core
  # Class for managing state transitions in an Ephesus application. Each session
  # belongs to an application and has a controller corresponding to the
  # application state.
  class Session
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    class << self
      def controller(controller_type, **conditionals)
        hsh = { type: controller_type }
        hsh = hsh.merge(if: conditionals[:if]) if conditionals.key?(:if)

        if conditionals.key?(:unless)
          hsh = hsh.merge(unless: conditionals[:unless])
        end

        controllers << hsh
      end

      private

      def controllers
        @controllers ||= []
      end
    end

    def initialize(application)
      @application = application
    end

    attr_reader :application

    delegate \
      :event_dispatcher,
      :state,
      to: :@application

    delegate \
      :execute_action,
      to: :controller

    def controller
      return @controller if @controller && @controller.state == state

      controller_type = current_controller

      if controller_type.nil?
        raise NotImplementedError,
          "unknown controller for state #{state.inspect}"
      end

      @controller = build_controller(controller_type)
    end

    private

    def build_controller(controller_type)
      controller_class(controller_type).new(
        state,
        event_dispatcher: event_dispatcher,
        repository: application.repository
      )
    end

    def controller_class(controller_type)
      return controller_type if controller_type.is_a?(Class)

      Object.const_get(controller_type)
    end

    def current_controller
      self
        .class
        .send(:controllers)
        .find { |hsh| match_controller?(hsh) }
        &.yield_self { |hsh| hsh[:type] }
    end

    def match_controller?(hsh)
      return false if hsh.key?(:if)     && !hsh[:if].call(state)
      return false if hsh.key?(:unless) && hsh[:unless].call(state)

      true
    end
  end
end
