# frozen_string_literal: true

require 'ephesus/core/events/event_registry'

module Ephesus::Flight
  module Events
    include Ephesus::Core::Events::EventRegistry

    event :GrantTakeoffClearance

    event :RadioOff
    event :RadioOn

    event :Taxi, :to
  end
end
