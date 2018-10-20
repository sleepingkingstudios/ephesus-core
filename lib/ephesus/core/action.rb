# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'cuprum/command'

require 'ephesus/core'
require 'ephesus/core/actions/dsl'
require 'ephesus/core/actions/hooks'
require 'ephesus/core/actions/result'

module Ephesus::Core
  # Abstract base class for Ephesus actions. Takes and stores a state object
  # representing the current game state.
  class Action < Cuprum::Command
    extend  SleepingKingStudios::Tools::Toolbox::Delegator
    include Ephesus::Core::Actions::Hooks
    include Ephesus::Core::Actions::Dsl

    def initialize(state, event_dispatcher:, repository: nil)
      @state            = state
      @event_dispatcher = event_dispatcher
      @repository       = repository
    end

    attr_reader :event_dispatcher

    attr_reader :repository

    attr_reader :state

    delegate :dispatch_event, to: :event_dispatcher

    private

    def build_result(value = nil, **options)
      Ephesus::Core::Actions::Result.new(value, options)
    end
  end
end
