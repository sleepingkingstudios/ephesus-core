# frozen_string_literal: true

require 'ephesus/core/action'
require 'ephesus/flight/actions'
require 'ephesus/flight/events'

module Ephesus::Flight::Actions
  class Takeoff < Ephesus::Core::Action
    private

    def process
      event = Ephesus::Flight::Events::Takeoff.new

      dispatch_event(event)
    end
  end
end
