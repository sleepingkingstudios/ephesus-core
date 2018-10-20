# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'ephesus/core/actions'

module Ephesus::Core::Actions
  # Processing hooks for evaluating code before and after an Action is called.
  module Hooks
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to include in Ephesus::Core::Action.
    module ClassMethods
      def after(status = nil, **options, &block)
        raise ArgumentError, 'must provide a block' unless block_given?

        status = guard_status!(status)

        after_hooks << {
          proc:   block,
          status: status,
          if:     options[:if],
          unless: options[:unless]
        }
      end

      def before(&block)
        raise ArgumentError, 'must provide a block' unless block_given?

        before_hooks << block
      end

      private

      def after_hooks
        @after_hooks ||= []
      end

      def before_hooks
        @before_hooks ||= []
      end

      def guard_status!(status)
        return nil if status.nil?

        status = status.intern

        return status if %i[success failure].include?(status)

        raise ArgumentError, "invalid result status #{status.inspect}"
      end
    end

    private

    def evaluate_conditional(result, conditional)
      if conditional.is_a?(Proc)
        conditional.arity.zero? ? conditional.call : conditional.call(result)
      else
        send(conditional, result)
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def process_with_result(result, *args, &block)
      self.class.send(:before_hooks).each do |proc|
        instance_exec(result, &proc)
      end

      super.tap do |returned|
        self.class.send(:after_hooks).each do |hsh|
          next if hsh[:status] == :success && !returned.success?
          next if hsh[:status] == :failure && !returned.failure?
          next if hsh[:if]     && !evaluate_conditional(returned, hsh[:if])
          next if hsh[:unless] &&  evaluate_conditional(returned, hsh[:unless])

          instance_exec(returned, &hsh[:proc])
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
