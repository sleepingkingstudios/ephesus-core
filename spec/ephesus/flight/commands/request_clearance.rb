# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/commands'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Commands
  class RequestClearance < Ephesus::Core::Command
    description 'Request permission to take off or land.'

    full_description <<~DESCRIPTION
      Contact the control tower.

      If you are currently on the ground, request clearance to take off.

      If you are currently flying, request clearance to land.
    DESCRIPTION

    example 'request clearance',
      description: 'Request takeoff clearance.',
      header:      'When Landed'

    example 'request clearance',
      description: 'Request landing clearance.',
      header:      'When Flying'

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
