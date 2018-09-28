# frozen_string_literal: true

require 'ephesus/core/action'
require 'ephesus/flight/actions'
require 'ephesus/flight/events'

module Ephesus::Flight::Actions
  class RequestClearance < Ephesus::Core::Action
    private

    def clearance_event
      if state.get(:landed)
        return Ephesus::Flight::Events::GrantTakeoffClearance.new
      end

      Ephesus::Flight::Events::GrantLandingClearance.new
    end

    def process
      dispatch_event(clearance_event)
    end
  end
end
