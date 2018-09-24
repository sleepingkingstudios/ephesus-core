# frozen_string_literal: true

require 'ephesus/core/action'
require 'ephesus/flight/actions'
require 'ephesus/flight/events'

module Ephesus::Flight::Actions
  class RadioOn < Ephesus::Core::Action
    private

    def process
      event = Ephesus::Flight::Events::RadioOn.new

      dispatch_event(event)
    end
  end
end
