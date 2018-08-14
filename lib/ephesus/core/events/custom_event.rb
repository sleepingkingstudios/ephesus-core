# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'ephesus/core/events'

module Ephesus::Core::Events
  # Constructor mixin for custom Ephesus events with a defined event_type.
  module CustomEvent
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods for a custom Ephesus event.
    module ClassMethods
      private

      def default_data
        {}
      end
    end

    def initialize(**data)
      super(nil, self.class.send(:default_data).merge(data))
    end
  end
end
