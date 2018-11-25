# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/commands'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Commands
  class Taxi < Ephesus::Core::Command
    VALID_DESTINATIONS = %w[hangar runway tarmac].freeze

    description 'Move to another part of the airport.'

    full_description <<~DESCRIPTION
      Move to another part of the airport. You can move to the hangar, the
      tarmac, and the runway.
    DESCRIPTION

    keyword :to, required: true

    private

    def process(to:)
      unless VALID_DESTINATIONS.include?(to)
        result.errors[:destination].add(:invalid, to: to)

        return
      end

      if state.get(:location) == to
        result.errors[:destination].add(:already_at_destination, to: to)

        return
      end

      dispatch(Ephesus::Flight::State::Actions.taxi to: to)
    end
  end
end
