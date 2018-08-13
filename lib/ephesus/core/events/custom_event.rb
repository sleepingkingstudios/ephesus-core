# frozen_string_literal: true

require 'ephesus/core/events'

module Ephesus::Core::Events
  # Constructor mixin for custom Ephesus events with a defined event_type.
  module CustomEvent
    def initialize(**data)
      super(nil, data)
    end
  end
end
