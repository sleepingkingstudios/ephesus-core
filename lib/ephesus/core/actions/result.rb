# frozen_string_literal: true

require 'bronze/errors'
require 'cuprum/result'

require 'ephesus/core/actions'

module Ephesus::Core::Actions
  # Custom result subclass representing the result of calling an Ephesus action.
  # Includes additional metadata including the name of the called action.
  class Result < Cuprum::Result
    def initialize(
      value = nil,
      action_name: nil,
      arguments:   [],
      errors:      nil,
      keywords:    {}
    )
      super(value, errors: errors)

      @action_name = action_name
      @arguments   = arguments
      @keywords    = keywords
    end

    attr_accessor :action_name

    attr_accessor :arguments

    attr_accessor :keywords

    private

    def build_errors
      Bronze::Errors.new
    end
  end
end
