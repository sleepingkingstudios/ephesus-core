# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'ephesus/core/commands'
require 'ephesus/core/commands/signature'

module Ephesus::Core::Commands
  # Mixin for defining metadata properties for Ephesus commands.
  module Dsl
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to include in Ephesus::Core::Command.
    module ClassMethods
      def properties
        return @properties if @properties

        @properties = {
          arguments:        [],
          description:      nil,
          full_description: nil,
          keywords:         {}
        }
      end

      def signature
        @signature ||= Ephesus::Core::Commands::Signature.new(self)
      end

      private

      def argument(name, required: true)
        name = normalize_name(name)

        properties[:arguments] << {
          name:     name,
          required: required
        }
      end

      def description(string)
        properties[:description] = string
      end

      def full_description(string)
        properties[:full_description] = string
      end

      def keyword(name, required: false)
        name = normalize_name(name)

        properties[:keywords][name] = {
          name:     name,
          required: required
        }
      end

      def normalize_name(name)
        tools.string.underscore(name).gsub(/\s+/, '_').intern
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end
  end
end
