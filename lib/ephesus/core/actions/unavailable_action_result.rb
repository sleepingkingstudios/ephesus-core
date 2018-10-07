# frozen_string_literal: true

require 'ephesus/core/actions'
require 'ephesus/core/actions/result'

module Ephesus::Core::Actions
  # Predefined result, to be returned when an unavailable action is executed.
  class UnavailableActionResult < Ephesus::Core::Actions::Result
    def initialize(action_name, **keywords)
      super(nil, action_name: action_name, **keywords)

      errors.add :unavailable_action
    end
  end
end
