# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/actions/taxi'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class LandedController < Ephesus::Core::Controller
    action :taxi,        Ephesus::Flight::Actions::Taxi
  end
end