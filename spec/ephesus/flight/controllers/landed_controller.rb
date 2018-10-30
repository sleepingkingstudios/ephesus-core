# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/commands/radio_on'
require 'ephesus/flight/commands/takeoff'
require 'ephesus/flight/commands/taxi'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class LandedController < Ephesus::Core::Controller
    command :radio_tower, Ephesus::Flight::Commands::RadioOn
    command :take_off,
      Ephesus::Flight::Commands::Takeoff,
      if: lambda { |state|
        state.get(:location) == 'runway' && state.get(:takeoff_clearance)
      }
    command :taxi, Ephesus::Flight::Commands::Taxi
  end
end
