# frozen_string_literal: true

require 'ephesus/core/actions'
require 'ephesus/core/actions/result'

module Ephesus::Core::Actions
  # Predefined result, to be returned when an invalid action is executed.
  class InvalidActionResult < Ephesus::Core::Actions::Result
    def initialize(action_name = nil, **keywords)
      super(nil, action_name: action_name, **keywords)

      errors.add :invalid_action
    end
  end
end
