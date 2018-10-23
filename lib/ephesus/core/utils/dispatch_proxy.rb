# frozen_string_literal: true

require 'forwardable'

require 'ephesus/core/utils'

module Ephesus::Core::Utils
  # Wrapper class that encapsulates a store's #dispatch method without exposing
  # #subscribe or the store's current state.
  class DispatchProxy
    extend Forwardable

    def initialize(dispatcher)
      @dispatcher = dispatcher
    end

    def_delegators :@dispatcher, :dispatch
  end
end
