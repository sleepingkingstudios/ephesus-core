# frozen_string_literal: true

require 'ephesus/core/action'
require 'ephesus/flight/actions'
require 'ephesus/flight/events'

module Ephesus::Flight::Actions
  class RequestClearance < Ephesus::Core::Action
    private

    def process
      event = Ephesus::Flight::Events::GrantTakeoffClearance.new

      dispatch_event(event)
    end
  end
end
