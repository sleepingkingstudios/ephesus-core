# frozen_string_literal: true

require 'ephesus/core/reducer'
require 'ephesus/flight/events'

module Ephesus::Flight
  Reducer = Ephesus::Core::Reducer.new do
    update Ephesus::Flight::Events::TAXI, :taxi

    def taxi(state, event)
      state.put(:location, event.to)
    end
  end
end