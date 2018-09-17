# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'ephesus/core'

module Ephesus::Core
  # Class for managing state transitions in an Ephesus application. Each session
  # belongs to an application and has a controller corresponding to the
  # application state.
  class Session
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    def initialize(application)
      @application = application
    end

    attr_reader :application

    delegate \
      :event_dispatcher,
      :state,
      to: :@application

    def current_controller
      controller_type = controller_for(state)

      if controller_type.nil?
        raise NotImplementedError,
          "unknown controller for state #{state.inspect}"
      end

      build_controller(controller_type)
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

    def controller_for(_state)
      nil
    end
  end
end
