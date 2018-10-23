# frozen_string_literal: true

require 'forwardable'

require 'cuprum/command'

require 'ephesus/core'
require 'ephesus/core/actions/dsl'
require 'ephesus/core/actions/hooks'
require 'ephesus/core/actions/result'

module Ephesus::Core
  # Abstract base class for Ephesus actions. Takes and stores a state object
  # representing the current game state.
  class Action < Cuprum::Command
    extend  Forwardable
    include Ephesus::Core::Actions::Hooks
    include Ephesus::Core::Actions::Dsl

    def initialize(state, dispatcher:, event_dispatcher:, repository: nil)
      @state            = state
      @dispatcher       = dispatcher
      @event_dispatcher = event_dispatcher
      @repository       = repository
    end

    attr_reader :dispatcher

    attr_reader :event_dispatcher

    attr_reader :repository

    attr_reader :state

    def_delegators :@dispatcher, :dispatch

    def_delegators :event_dispatcher, :dispatch_event

    private

    def build_result(value = nil, **options)
      Ephesus::Core::Actions::Result.new(value, options)
    end
  end
end
