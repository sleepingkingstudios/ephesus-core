# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/actions/radio_on'
require 'ephesus/flight/actions/takeoff'
require 'ephesus/flight/actions/taxi'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class LandedController < Ephesus::Core::Controller
    action :radio_tower, Ephesus::Flight::Actions::RadioOn
    action :take_off,
      Ephesus::Flight::Actions::Takeoff,
      if: ->(state) { state.get(:takeoff_clearance) }
    action :taxi, Ephesus::Flight::Actions::Taxi
  end
end
