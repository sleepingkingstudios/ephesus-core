# frozen_string_literal: true

require 'ephesus/core/action'
require 'ephesus/flight/actions'
require 'ephesus/flight/events'

module Ephesus::Flight::Actions
  class Taxi < Ephesus::Core::Action
    VALID_DESTINATIONS = %w[hangar runway tarmac].freeze

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

      event = Ephesus::Flight::Events::Taxi.new(to: to)

      dispatch_event(event)
    end
  end
end
