# frozen_string_literal: true

require 'ephesus/core/reducer'
require 'ephesus/flight/events'

module Ephesus::Flight
  Reducer = Ephesus::Core::Reducer.new do
    update Ephesus::Flight::Events::GRANT_TAKEOFF_CLEARANCE do |state, _event|
      state.put(:takeoff_clearance, true)
    end
    update Ephesus::Flight::Events::RADIO_OFF do |state, _event|
      state.put(:radio, false)
    end
    update Ephesus::Flight::Events::RADIO_ON do |state, _event|
      state.put(:radio, true)
    end

    update Ephesus::Flight::Events::TAXI, :taxi

    def taxi(state, event)
      state.put(:location, event.to)
    end
  end
end
