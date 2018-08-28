# frozen_string_literal: true

require 'ephesus/core/events/event_registry'

module Ephesus::Core::Events
  # Event registry for events that operate on Ephesus controllers.
  module ControllerEvents
    include Ephesus::Core::Events::EventRegistry

    event :start_controller, :controller_type, :controller_params
    event :stop_controller,  :identifier
    event :stop_current_controller
  end
end
