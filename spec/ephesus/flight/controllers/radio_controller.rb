# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/commands/radio_off'
require 'ephesus/flight/commands/request_clearance'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class RadioController < Ephesus::Core::Controller
    command :request_clearance,
      Ephesus::Flight::Commands::RequestClearance,
      if: lambda { |state|
        (state.get(:landed) && !state.get(:takeoff_clearance)) ||
          (!state.get(:landed) && !state.get(:landing_clearance))
      }

    command :turn_off_radio, Ephesus::Flight::Commands::RadioOff
  end
end
