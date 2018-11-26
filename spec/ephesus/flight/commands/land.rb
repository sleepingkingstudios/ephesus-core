# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/commands'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Commands
  class Land < Ephesus::Core::Command
    description 'Land on the runway.'

    private

    def process
      dispatch(Ephesus::Flight::State::Actions.land)
    end
  end
end
