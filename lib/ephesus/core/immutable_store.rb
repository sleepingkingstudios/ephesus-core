# frozen_string_literal: true

require 'zinke/store'

require 'ephesus/core'
require 'ephesus/core/utils/immutable'

module Ephesus::Core
  # Implementation of Zinke::Store that wrap the given or default state in an
  # immutable data structure, courtesy of the Hamster gem.
  class ImmutableStore < Zinke::Store
    def initialize(state = nil, options = nil)
      state =
        Ephesus::Core::Utils::Immutable.from_object(state || initial_state)

      super(state, options)
    end
  end
end
