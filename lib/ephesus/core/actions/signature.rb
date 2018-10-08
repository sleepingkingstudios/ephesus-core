# frozen_string_literal: true

require 'ephesus/core/actions'
require 'ephesus/core/actions/invalid_arguments_result'

module Ephesus::Core::Actions
  # Utility class representing the expected parameters of an action. Can match
  # the actual arguments and keywords against the expectation and generate an
  # error result on a failed match.
  class Signature
    def initialize(action_class)
      @action_class = action_class

      count_arguments
      check_keywords
    end

    attr_reader :action_class

    attr_reader :allowed_keywords

    attr_reader :max_argument_count

    attr_reader :min_argument_count

    attr_reader :optional_keywords

    attr_reader :required_keywords

    def match(*arguments, **keywords)
      @result = nil

      count = arguments.size
      guard_min_arguments(count)
      guard_max_arguments(count)

      keys = keywords.keys
      guard_allowed_keywords(keys)
      guard_required_keywords(keys)

      [@result.nil?, @result]
    end

    private

    def check_keywords
      @allowed_keywords  = []
      @optional_keywords = []
      @required_keywords = []

      action_class.properties[:keywords].each do |key, hsh|
        @allowed_keywords << key

        (hsh[:required] ? @required_keywords : @optional_keywords) << key
      end
    end

    def count_arguments
      arguments           = action_class.properties[:arguments]
      @min_argument_count = arguments.select { |hsh| hsh[:required] }.size
      @max_argument_count = arguments.size
    end

    def guard_allowed_keywords(keys)
      invalid_keys = keys - allowed_keywords

      return if invalid_keys.empty?

      result.errors[:arguments].add(
        :invalid_keywords,
        actual:   keys,
        expected: allowed_keywords,
        invalid:  invalid_keys
      )
    end

    def guard_max_arguments(count)
      return unless count > max_argument_count

      result.errors[:arguments].add(
        :too_many_arguments,
        actual:   count,
        expected: max_argument_count
      )
    end

    def guard_min_arguments(count)
      return unless count < min_argument_count

      result.errors[:arguments].add(
        :not_enough_arguments,
        actual:   count,
        expected: min_argument_count
      )
    end

    def guard_required_keywords(keys)
      missing_keys = required_keywords - keys

      return if missing_keys.empty?

      result.errors[:arguments].add(
        :missing_keywords,
        actual:   keys,
        expected: required_keywords,
        missing:  missing_keys
      )
    end

    def result
      @result ||= Ephesus::Core::Actions::InvalidArgumentsResult.new
    end
  end
end
