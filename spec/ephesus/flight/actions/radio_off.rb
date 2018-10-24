# frozen_string_literal: true

require 'ephesus/core/action'
require 'ephesus/flight/actions'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Actions
  class RadioOff < Ephesus::Core::Action
    private

    def process
      dispatch(Ephesus::Flight::State::Actions.radio_off)
    end
  end
end
