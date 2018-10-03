# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/flight/reducer'

module Ephesus::Flight
  class Application < Ephesus::Core::Application
    include Ephesus::Flight::Reducer

    private

    def initial_state
      {
        landed:            true,
        landing_clearance: false,
        location:          'hangar',
        radio:             false,
        takeoff_clearance: false
      }
    end
  end
end
