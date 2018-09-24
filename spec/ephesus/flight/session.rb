# frozen_string_literal: true

require 'ephesus/core/session'
require 'ephesus/flight/controllers/landed_controller'
require 'ephesus/flight/controllers/radio_controller'

module Ephesus::Flight
  class Session < Ephesus::Core::Session
    controller Ephesus::Flight::Controllers::RadioController,
      if: ->(state) { state.get(:radio) }

    controller Ephesus::Flight::Controllers::LandedController
  end
end
