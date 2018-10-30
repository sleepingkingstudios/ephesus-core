# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/commands'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Commands
  class RadioOff < Ephesus::Core::Command
    private

    def process
      dispatch(Ephesus::Flight::State::Actions.radio_off)
    end
  end
end
