# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/commands'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Commands
  class RadioOn < Ephesus::Core::Command
    description 'Turn on the radio.'

    private

    def process
      dispatch(Ephesus::Flight::State::Actions.radio_on)
    end
  end
end
