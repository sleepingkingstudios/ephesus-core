# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/actions'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Actions
  class RadioOn < Ephesus::Core::Command
    private

    def process
      dispatch(Ephesus::Flight::State::Actions.radio_on)
    end
  end
end
