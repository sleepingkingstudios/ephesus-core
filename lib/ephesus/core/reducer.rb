# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'ephesus/core'

module Ephesus::Core
  # State management class. Applications should include Reducer instances to
  # define state transitions, defined using the Reducer#update method.
  class Reducer < Module
    def update(event_type, method_name = nil, &block)
      if block_given?
        @listeners = listeners.push([event_type, block])
      elsif method_name
        @listeners = listeners.push([event_type, method_name])
      else
        raise ArgumentError, 'must provide a method name or block'
      end
    end

    def listeners
      @listeners ||= Hamster::Vector.new
    end
  end
end
