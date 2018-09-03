# frozen_string_literal: true

require 'ephesus/core/action'
require 'ephesus/core/actions'
require 'ephesus/core/events/controller_events'

module Ephesus::Core::Actions
  # Ephesus action to dispatch a STOP_ALL_CONTROLLERS action, e.g. when quitting
  # an application.
  class StopAllControllers < Ephesus::Core::Action
    private

    def process
      dispatch_event(stop_event)
    end

    def stop_event
      Ephesus::Core::Events::ControllerEvents::StopAllControllers.new
    end
  end
end
