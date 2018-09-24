# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/flight/reducer'

module Ephesus::Flight
  class Application < Ephesus::Core::Application
    include Ephesus::Flight::Reducer

    private

    def initial_state
      {
        landed:   true,
        location: 'hangar'
      }
    end
  end
end
