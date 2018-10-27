# frozen_string_literal: true

require 'forwardable'

require 'cuprum/command'

require 'ephesus/core'
require 'ephesus/core/actions/dsl'
require 'ephesus/core/actions/hooks'
require 'ephesus/core/actions/result'

module Ephesus::Core
  # Abstract base class for Ephesus commands. Takes and stores a state object
  # representing the current game state, a dispatcher to dispatch state updates,
  # and optional params passed from the controller object.
  class Command < Cuprum::Command
    extend  Forwardable
    include Ephesus::Core::Actions::Hooks
    include Ephesus::Core::Actions::Dsl

    def initialize(state, dispatcher:, **options)
      @state      = state
      @dispatcher = dispatcher
      @options    = options
    end

    attr_reader :dispatcher

    attr_reader :options

    attr_reader :state

    def_delegators :@dispatcher, :dispatch

    private

    def build_result(value = nil, **options)
      Ephesus::Core::Actions::Result.new(value, options)
    end
  end
end
