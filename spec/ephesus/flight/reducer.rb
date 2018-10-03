# frozen_string_literal: true

require 'ephesus/core/reducer'
require 'ephesus/flight/events'

module Ephesus::Flight
  Reducer = Ephesus::Core::Reducer.new do
    update Ephesus::Flight::Events::GRANT_LANDING_CLEARANCE do |state, _event|
      state.put(:landing_clearance, true)
    end
    update Ephesus::Flight::Events::GRANT_TAKEOFF_CLEARANCE do |state, _event|
      state.put(:takeoff_clearance, true)
    end
    update Ephesus::Flight::Events::RADIO_OFF do |state, _event|
      state.put(:radio, false)
    end
    update Ephesus::Flight::Events::RADIO_ON do |state, _event|
      state.put(:radio, true)
    end

    update Ephesus::Flight::Events::LAND,         :land
    update Ephesus::Flight::Events::TAKEOFF,      :take_off
    update Ephesus::Flight::Events::TAXI,         :taxi
    update Ephesus::Flight::Events::UPDATE_SCORE, :update_score

    def land(state, _event)
      state
        .put(:landed, true)
        .put(:landing_clearance, false)
        .put(:location, 'runway')
    end

    def take_off(state, _event)
      state
        .put(:landed, false)
        .put(:location, nil)
        .put(:takeoff_clearance, false)
    end

    def taxi(state, event)
      state.put(:location, event.to)
    end

    def update_score(state, event)
      score = state.fetch(:score, 0)

      state.put(:score, score + event.by)
    end
  end
end
