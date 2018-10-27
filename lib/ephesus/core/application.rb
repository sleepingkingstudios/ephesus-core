# frozen_string_literal: true

require 'forwardable'

require 'ephesus/core/immutable_store'

module Ephesus::Core
  # Base class for Ephesus applications. An application has a single state
  # managed by an immutable store, and can be referenced by one or many
  # sessions. Applications can also reference additional resources, such as a
  # data repository.
  class Application
    extend Forwardable

    def initialize(state: nil)
      @store = build_store(state || initial_state)
    end

    def_delegator :@store, :state

    attr_reader :store

    private

    def build_store(state)
      Ephesus::Core::ImmutableStore.new(state)
    end

    def initial_state
      nil
    end
  end
end
