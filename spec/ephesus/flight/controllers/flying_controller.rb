# frozen_string_literal: true

require 'ephesus/core/controller'
require 'ephesus/flight/commands/do_trick'
require 'ephesus/flight/commands/land'
require 'ephesus/flight/commands/radio_on'
require 'ephesus/flight/controllers'

module Ephesus::Flight::Controllers
  class FlyingController < Ephesus::Core::Controller
    command :do_trick, Ephesus::Flight::Commands::DoTrick

    command :land,
      Ephesus::Flight::Commands::Land,
      if: ->(state) { state.get(:landing_clearance) }

    command :radio_tower, Ephesus::Flight::Commands::RadioOn
  end
end
