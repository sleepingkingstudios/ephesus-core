# frozen_string_literal: true

require 'forwardable'

require 'cuprum/command'

require 'ephesus/core'
require 'ephesus/core/commands/dsl'
require 'ephesus/core/commands/hooks'
require 'ephesus/core/commands/result'

module Ephesus::Core
  # Abstract base class for Ephesus commands. Takes and stores a state object
  # representing the current game state, a dispatcher to dispatch state updates,
  # and optional params passed from the controller object.
  class Command < Cuprum::Command
    extend  Forwardable
    include Ephesus::Core::Commands::Dsl
    include Ephesus::Core::Commands::Hooks

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
      Ephesus::Core::Commands::Result.new(value, options)
    end
  end
end
