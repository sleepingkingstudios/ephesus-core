# frozen_string_literal: true

require 'ephesus/flight/state'

module Ephesus::Flight::State
  module Actions
    GRANT_LANDING_CLEARANCE =
      'ephesus.flight.state.actions.grant_landing_clearance'

    GRANT_TAKEOFF_CLEARANCE =
      'ephesus.flight.state.actions.grant_takeoff_clearance'

    LAND =
      'ephesus.flight.state.actions.land'

    RADIO_OFF =
      'ephesus.flight.state.actions.radio_off'

    RADIO_ON =
      'ephesus.flight.state.actions.radio_on'

    TAKEOFF =
      'ephesus.flight.state.actions.takeoff'

    TAXI =
      'ephesus.flight.state.actions.taxi'

    UPDATE_SCORE =
      'ephesus.flight.state.actions.update_score'

    def self.grant_landing_clearance
      { type: GRANT_LANDING_CLEARANCE }
    end

    def self.grant_takeoff_clearance
      { type: GRANT_TAKEOFF_CLEARANCE }
    end

    def self.land
      { type: LAND }
    end

    def self.radio_off
      { type: RADIO_OFF }
    end

    def self.radio_on
      { type: RADIO_ON }
    end

    def self.takeoff
      { type: TAKEOFF }
    end

    def self.taxi(to:)
      {
        destination: to,
        type:        TAXI
      }
    end

    def self.update_score(by:)
      {
        amount: by,
        type:   UPDATE_SCORE
      }
    end
  end
end
