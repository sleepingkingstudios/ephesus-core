# frozen_string_literal: true

require 'zinke/reducer'

require 'ephesus/flight/state'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::State
  module Reducer
    include Zinke::Reducer

    update(Ephesus::Flight::State::Actions::GRANT_LANDING_CLEARANCE) \
      { |state| state.put(:landing_clearance) { true } }

    update(Ephesus::Flight::State::Actions::GRANT_TAKEOFF_CLEARANCE) \
      { |state| state.put(:takeoff_clearance) { true } }

    update Ephesus::Flight::State::Actions::LAND, :handle_land

    update(Ephesus::Flight::State::Actions::RADIO_OFF) \
      { |state| state.put(:radio) { false } }

    update(Ephesus::Flight::State::Actions::RADIO_ON) \
      { |state| state.put(:radio) { true } }

    update Ephesus::Flight::State::Actions::TAKEOFF, :handle_takeoff

    update(Ephesus::Flight::State::Actions::TAXI) \
      { |state, action| state.merge(location: action[:destination]) }

    update Ephesus::Flight::State::Actions::UPDATE_SCORE, :handle_update_score

    private

    def handle_land(state, _action)
      state.merge(
        landed:            true,
        landing_clearance: false,
        location:          'runway'
      )
    end

    def handle_takeoff(state, _action)
      state.merge(
        landed:            false,
        location:          nil,
        takeoff_clearance: false
      )
    end

    def handle_update_score(state, action)
      score = state.get(:score) + action[:amount]

      state.merge(score: score)
    end
  end
end
