# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/actions/radio_off'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class RadioController < Ephesus::Core::Controller
    action :turn_off_radio, Ephesus::Flight::Actions::RadioOff
  end
end
