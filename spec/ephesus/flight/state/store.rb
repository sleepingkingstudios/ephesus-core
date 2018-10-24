# frozen_string_literal: true

require 'ephesus/core/immutable_store'
require 'ephesus/flight/state'

module Ephesus::Flight::State
  class Store < Ephesus::Core::ImmutableStore
    private

    def initial_state
      {
        landed:            true,
        landing_clearance: false,
        location:          'hangar',
        radio:             false,
        score:             0,
        takeoff_clearance: false
      }
    end
  end
end
