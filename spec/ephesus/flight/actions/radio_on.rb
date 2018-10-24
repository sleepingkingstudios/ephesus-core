# frozen_string_literal: true

require 'ephesus/core/action'
require 'ephesus/flight/actions'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Actions
  class RadioOn < Ephesus::Core::Action
    private

    def process
      dispatch(Ephesus::Flight::State::Actions.radio_on)
    end
  end
end
