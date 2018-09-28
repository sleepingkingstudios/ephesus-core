# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/actions/land'
require 'ephesus/flight/actions/radio_on'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class FlyingController < Ephesus::Core::Controller
    action :land,
      Ephesus::Flight::Actions::Land,
      if: ->(state) { state.get(:landing_clearance) }

    action :radio_tower, Ephesus::Flight::Actions::RadioOn
  end
end
