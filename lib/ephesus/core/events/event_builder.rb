# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

require 'ephesus/core/event'
require 'ephesus/core/events/custom_event'

module Ephesus::Core::Events
  # Builder class for generating subclasses of Ephesus::Event with a defined
  # event_type and, optionally, data keys with defined property accessors.
  class EventBuilder
    def initialize(parent_class = nil)
      @parent_class = parent_class || Ephesus::Core::Event
    end

    attr_reader :parent_class

    def build(event_type, event_keys)
      @subclass_type = event_type
      @subclass_keys = normalize_event_keys(event_keys)
      @event_class   = build_event_class

      define_event_type
      define_keys
      set_default_data

      event_class
    end

    private

    attr_reader :event_class, :subclass_keys, :subclass_type

    def build_event_class
      Class.new(parent_class) do
        unless self < Ephesus::Core::Events::CustomEvent
          include Ephesus::Core::Events::CustomEvent
        end
      end
    end

    def define_event_type
      event_types = parent_event_types + [subclass_type]

      event_class.define_singleton_method(:event_types) do
        super() + event_types
      end
    end

    def define_key_reader(event_key)
      return if event_class.methods.include?(event_key)

      event_class.define_method(event_key) { data[event_key] }
    end

    def define_key_writer(event_key)
      key_writer = :"#{event_key}="

      return if event_class.methods.include?(key_writer)

      event_class.define_method(key_writer) { |value| data[event_key] = value }
    end

    def define_keys
      subclass_keys.each do |key|
        define_key_reader(key)
        define_key_writer(key)
      end

      event_keys = (parent_class.keys + subclass_keys).sort

      define_keys_class_reader(event_keys)
    end

    def define_keys_class_reader(event_keys)
      event_keys = Set.new(event_keys).freeze

      event_class.define_singleton_method(:keys) { event_keys }
    end

    def normalize_event_keys(event_keys)
      event_keys
        .map { |str| tools.string.underscore(str) }
        .map(&:intern)
    end

    def parent_default_data
      return {} unless parent_class.respond_to?(:default_data)

      parent_class.send(:default_data)
    end

    def parent_event_types
      return [] unless parent_class.respond_to?(:event_types)

      parent_class.send(:event_types)
    end

    def set_default_data
      default_data = parent_default_data

      subclass_keys.each { |key| default_data[key] ||= nil }

      event_class.define_singleton_method(:default_data) { default_data }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
