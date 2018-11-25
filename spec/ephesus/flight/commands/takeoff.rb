# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/commands'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Commands
  class Takeoff < Ephesus::Core::Command
    description 'Soar into the sky!'

    private

    def process
      dispatch(Ephesus::Flight::State::Actions.takeoff)
    end
  end
end
