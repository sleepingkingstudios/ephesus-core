# frozen_string_literal: true

require 'bronze/errors'
require 'cuprum/result'

require 'ephesus/core/actions'

module Ephesus::Core::Actions
  # Custom result subclass representing the result of calling an Ephesus action.
  # Includes additional metadata including the name of the called action.
  class Result < Cuprum::Result
    def initialize(value = nil, action_name: nil, errors: nil)
      super(value, errors: errors)

      @action_name = action_name
    end

    attr_accessor :action_name

    private

    def build_errors
      Bronze::Errors.new
    end
  end
end
