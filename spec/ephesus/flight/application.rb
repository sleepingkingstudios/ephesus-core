# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/flight/state/store'

module Ephesus::Flight
  class Application < Ephesus::Core::Application
    private

    def build_store(state)
      Ephesus::Flight::State::Store.new(state)
    end
  end
end
