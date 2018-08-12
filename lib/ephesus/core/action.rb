# frozen_string_literal: true

require 'bronze/errors'
require 'cuprum/command'

require 'ephesus/core'

module Ephesus::Core
  # Abstract base class for Ephesus actions. Takes and stores a session object
  # representing the current game state.
  class Action < Cuprum::Command
    def initialize(session)
      @session = session
    end

    attr_reader :session

    private

    def build_errors
      Bronze::Errors.new
    end
  end
end
