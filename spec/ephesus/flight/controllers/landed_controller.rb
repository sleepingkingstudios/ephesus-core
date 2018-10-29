# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/actions/radio_on'
require 'ephesus/flight/actions/takeoff'
require 'ephesus/flight/actions/taxi'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class LandedController < Ephesus::Core::Controller
    command :radio_tower, Ephesus::Flight::Actions::RadioOn
    command :take_off,
      Ephesus::Flight::Actions::Takeoff,
      if: lambda { |state|
        state.get(:location) == 'runway' && state.get(:takeoff_clearance)
      }
    command :taxi, Ephesus::Flight::Actions::Taxi
  end
end
