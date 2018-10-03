# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/actions/radio_off'
require 'ephesus/flight/actions/request_clearance'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class RadioController < Ephesus::Core::Controller
    action :request_clearance,
      Ephesus::Flight::Actions::RequestClearance,
      if: lambda { |state|
        (state.get(:landed) && !state.get(:takeoff_clearance)) ||
          (!state.get(:landed) && !state.get(:landing_clearance))
      }

    action :turn_off_radio, Ephesus::Flight::Actions::RadioOff
  end
end
