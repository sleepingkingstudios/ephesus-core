# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/actions'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Actions
  class RequestClearance < Ephesus::Core::Command
    private

    def process
      action =
        if state.get(:landed)
          Ephesus::Flight::State::Actions.grant_takeoff_clearance
        else
          Ephesus::Flight::State::Actions.grant_landing_clearance
        end

      dispatch(action)
    end
  end
end
