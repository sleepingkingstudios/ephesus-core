# frozen_string_literal: true

require 'ephesus/core/session'
require 'ephesus/flight/controllers/landed_controller'

module Ephesus::Flight
  class Session < Ephesus::Core::Session
    controller Ephesus::Flight::Controllers::LandedController
  end
end
