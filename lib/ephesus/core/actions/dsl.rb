# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'ephesus/core/actions'
require 'ephesus/core/actions/signature'

module Ephesus::Core::Actions
  # Mixin for defining metadata properties for Ephesus actions.
  module Dsl
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to include in Ephesus::Core::Action.
    module ClassMethods
      def properties
        return @properties if @properties

        @properties = {
          arguments: [],
          keywords:  {}
        }
      end

      def signature
        @signature ||= Ephesus::Core::Actions::Signature.new(self)
      end

      private

      def argument(name, required: true)
        name = normalize_name(name)

        properties[:arguments] << {
          name:     name,
          required: required
        }
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
