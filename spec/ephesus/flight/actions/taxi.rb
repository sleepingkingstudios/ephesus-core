# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/flight/actions'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Actions
  class Taxi < Ephesus::Core::Command
    VALID_DESTINATIONS = %w[hangar runway tarmac].freeze

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
