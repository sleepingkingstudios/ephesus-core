# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/actions'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Actions
  class RadioOff < Ephesus::Core::Command
    private

    def process
      dispatch(Ephesus::Flight::State::Actions.radio_off)
    end
  end
end
