# frozen_string_literal: true

require 'ephesus/core/events/event_registry'

module Ephesus::Flight
  module Events
    include Ephesus::Core::Events::EventRegistry
    event :Taxi, :to
  end
end
