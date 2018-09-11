# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils'

module Ephesus::Core::Utils
  # Utility methods for converting to and from immutable objects.
  module Immutable # rubocop:disable Metrics/ModuleLength
    IMMUTABLE_DATA_STRUCTURES = [
      Hamster::Hash,
      Hamster::List,
      Hamster::Set,
      Hamster::SortedSet,
      Hamster::Vector
    ].freeze

    class << self
      def dig(immutable, *keys)
        unless IMMUTABLE_DATA_STRUCTURES.any? { |klass| immutable.is_a?(klass) }
          raise ArgumentError, 'argument must be an immutable data structure'
        end

        dig_object(immutable, keys)
      end

      def from_array(ary)
        raise ArgumentError, 'argument must be an Array' unless ary.is_a?(Array)

        data = ary.map { |obj| from_object(obj) }

        Hamster::Vector.new(data)
      end

      # rubocop:disable Metrics/MethodLength
      def from_object(obj)
        case obj
        when Array
          from_array(obj)
        when Hash
          from_hash(obj)
        when Set
          from_set(obj)
        when String
          obj.freeze
        else
          obj
        end
      end
      # rubocop:enable Metrics/MethodLength

      def from_hash(hsh)
        raise ArgumentError, 'argument must be a Hash' unless hsh.is_a?(Hash)

        tools = SleepingKingStudios::Tools::Toolbelt.instance
        data  = tools.hash.convert_keys_to_symbols(hsh)
        data  = data.map { |key, value| [key, from_object(value)] }

        Hamster::Hash.new(data)
      end

      def from_set(set)
        raise ArgumentError, 'argument must be a Set' unless set.is_a?(Set)

        data = set.map { |obj| from_object(obj) }

        Hamster::Set.new(data)
      end

      def to_array(immutable)
        unless immutable.is_a?(Hamster::Vector)
          raise ArgumentError, 'argument must be a Hamster::Vector'
        end

        immutable.map { |item| to_object(item) }.to_a
      end

      def to_hash(immutable)
        unless immutable.is_a?(Hamster::Hash)
          raise ArgumentError, 'argument must be a Hamster::Hash'
        end

        data = immutable.map do |key, value|
          [key, to_object(value)]
        end

        Hash[data]
      end

      def to_object(immutable)
        case immutable
        when Hamster::Hash
          to_hash(immutable)
        when Hamster::Set
          to_set(immutable)
        when Hamster::Vector
          to_array(immutable)
        else
          immutable
        end
      end

      def to_set(immutable)
        unless immutable.is_a?(Hamster::Set)
          raise ArgumentError, 'argument must be a Hamster::Set'
        end

        data = immutable.map { |item| to_object(item) }

        Set.new(data)
      end

      private

      def dig_keyed(hsh, key, *rest)
        obj = hsh[key]

        rest.empty? ? obj : dig_object(obj, rest)
      end

      def dig_indexed(vec, key, *rest)
        obj = vec[key]

        rest.empty? ? obj : dig_object(obj, rest)
      end

      # rubocop:disable Metrics/MethodLength
      def dig_object(obj, keys)
        case obj
        when nil
          nil
        when Hamster::Hash
          dig_keyed(obj, *keys)
        when Hamster::List, Hamster::SortedSet, Hamster::Vector
          dig_indexed(obj, *keys)
        when ->(_) { obj.respond_to?(:dig) }
          # :nocov:
          obj.dig(*keys)
          # :nocov:
        else
          raise TypeError, "#{obj.class} does not have #dig method"
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
