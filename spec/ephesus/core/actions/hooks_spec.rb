# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/action'
require 'ephesus/core/utils/dispatch_proxy'

RSpec.describe Ephesus::Core::Actions::Hooks do
  shared_context 'when the action has chained commands' do
    let(:chained_command) { Cuprum::Command.new }
    let(:chained_result)  { Cuprum::Result.new 'chained result' }
    let(:expected_result) { chained_result }
    let(:action) do
      super()
        .chain { 'second result' }
        .chain { 'third result' }
        .chain(chained_command)
    end

    before(:example) do
      allow(chained_command).to receive(:process).and_return(chained_result)
    end
  end

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy)
  end
  let(:result)           { Cuprum::Result.new 'first result' }
  let(:expected_result)  { result }
  let(:action_class)     { Spec::ExampleAction }
  let(:state)            { {} }
  let(:action) do
    action_class.new(state, dispatcher: dispatcher)
  end

  example_class 'Spec::ExampleAction', base_class: Ephesus::Core::Action \
  do |klass|
    klass.send :include, described_class
  end

  before(:example) { allow(action).to receive(:process).and_return(result) }

  describe '::after' do
    shared_examples 'should yield and return the last result' do
      it 'should return the result' do
        define_hook {}

        expect(action.call).to be expected_result
      end

      it 'should yield the last result to the block' do
        expect do |block|
          define_hook(&block)

          action.call
        end
          .to yield_with_args(expected_result)
      end
    end

    shared_examples 'should not yield the block' do
      it 'should not yield the block' do
        expect do |block|
          define_hook(&block)

          action.call
        end
          .not_to yield_control
      end
    end

    it 'should define the class method' do
      expect(action_class)
        .to respond_to(:after)
        .with(0..1).arguments
        .and_keywords(:if, :unless)
        .and_a_block
    end

    describe 'without a block' do
      it 'should raise an error' do
        expect { action_class.after }
          .to raise_error ArgumentError, 'must provide a block'
      end
    end

    describe 'with an invalid status' do
      it 'should raise an error' do
        expect { action_class.after(:on_fire) {} }
          .to raise_error ArgumentError, 'invalid result status :on_fire'
      end
    end

    describe 'with no arguments' do
      def define_hook(&block)
        action_class.after(&block)
      end

      it 'should evaluate the block in the context of the action instance' do
        context = nil

        define_hook { context = self }

        action.call

        expect(context).to be action
      end

      include_examples 'should yield and return the last result'

      wrap_context 'when the action has chained commands' do
        include_examples 'should yield and return the last result'
      end
    end

    # rubocop:disable RSpec/NestedGroups
    describe 'with :success' do
      def define_hook(&block)
        action_class.after(:success, &block)
      end

      context 'when the result is passing' do
        before(:example) do
          allow(expected_result).to receive(:success?).and_return(true)
        end

        include_examples 'should yield and return the last result'

        wrap_context 'when the action has chained commands' do
          include_examples 'should yield and return the last result'
        end
      end

      context 'when the result is failing' do
        before(:example) do
          allow(expected_result).to receive(:success?).and_return(false)
        end

        include_examples 'should not yield the block'

        wrap_context 'when the action has chained commands' do
          include_examples 'should not yield the block'
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    # rubocop:disable RSpec/NestedGroups
    describe 'with :failure' do
      def define_hook(&block)
        action_class.after(:failure, &block)
      end

      context 'when the result is passing' do
        before(:example) do
          allow(expected_result).to receive(:failure?).and_return(false)
        end

        include_examples 'should not yield the block'

        wrap_context 'when the action has chained commands' do
          include_examples 'should not yield the block'
        end
      end

      context 'when the result is failing' do
        before(:example) do
          allow(expected_result).to receive(:failure?).and_return(true)
        end

        include_examples 'should yield and return the last result'

        wrap_context 'when the action has chained commands' do
          include_examples 'should yield and return the last result'
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    # rubocop:disable RSpec/NestedGroups
    describe 'with if: block' do
      let(:conditional) { ->(_) {} }

      def define_hook(&block)
        action_class.after(if: conditional, &block)
      end

      context 'when the conditional block takes an argument' do
        it 'should yield the last result to the conditional block' do
          yielded     = nil
          conditional = ->(result) { yielded = result }

          action_class.after(if: conditional) {}

          action.call

          expect(yielded).to be result
        end
      end

      context 'when the conditional block returns true' do
        let(:conditional) { -> { true } }

        include_examples 'should yield and return the last result'

        wrap_context 'when the action has chained commands' do
          include_examples 'should yield and return the last result'
        end
      end

      context 'when the conditional block returns false' do
        let(:conditional) { -> { false } }

        include_examples 'should not yield the block'

        wrap_context 'when the action has chained commands' do
          include_examples 'should not yield the block'
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    # rubocop:disable RSpec/NestedGroups
    describe 'with if: method name' do
      let(:method_name) { :conditional_method }

      def define_hook(&block)
        action_class.after(if: method_name, &block)
      end

      context 'when the action does not define the method' do
        it 'should raise an error when called' do
          define_hook {}

          expect { action.call }
            .to raise_error NoMethodError,
              /undefined method `conditional_method'/
        end
      end

      context 'when the action defines the method' do
        # rubocop:disable RSpec/ExampleLength
        it 'should call the method with the last result' do
          arguments = nil

          action_class.after(if: method_name) {}

          action_class.send(:define_method, method_name) do |*args|
            arguments = args
          end

          action.call

          expect(arguments).to be == [expected_result]
        end
        # rubocop:enable RSpec/ExampleLength
      end

      context 'when the conditional block returns true' do
        before(:example) do
          action_class.send(:define_method, method_name) { |_| true }
        end

        include_examples 'should yield and return the last result'

        wrap_context 'when the action has chained commands' do
          include_examples 'should yield and return the last result'
        end
      end

      context 'when the conditional block returns false' do
        before(:example) do
          action_class.send(:define_method, method_name) { |_| false }
        end

        include_examples 'should not yield the block'

        wrap_context 'when the action has chained commands' do
          include_examples 'should not yield the block'
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    # rubocop:disable RSpec/NestedGroups
    describe 'with unless: block' do
      let(:conditional) { ->(_) {} }

      def define_hook(&block)
        action_class.after(unless: conditional, &block)
      end

      context 'when the conditional block takes an argument' do
        it 'should yield the last result to the conditional block' do
          yielded     = nil
          conditional = ->(result) { yielded = result }

          action_class.after(unless: conditional) {}

          action.call

          expect(yielded).to be result
        end
      end

      context 'when the conditional block returns true' do
        let(:conditional) { -> { true } }

        include_examples 'should not yield the block'

        wrap_context 'when the action has chained commands' do
          include_examples 'should not yield the block'
        end
      end

      context 'when the conditional block returns false' do
        let(:conditional) { -> { false } }

        include_examples 'should yield and return the last result'

        wrap_context 'when the action has chained commands' do
          include_examples 'should yield and return the last result'
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    # rubocop:disable RSpec/NestedGroups
    describe 'with unless: method name' do
      let(:method_name) { :conditional_method }

      def define_hook(&block)
        action_class.after(unless: method_name, &block)
      end

      context 'when the action does not define the method' do
        it 'should raise an error when called' do
          define_hook {}

          expect { action.call }
            .to raise_error NoMethodError,
              /undefined method `conditional_method'/
        end
      end

      context 'when the action defines the method' do
        # rubocop:disable RSpec/ExampleLength
        it 'should call the method with the last result' do
          arguments = nil

          action_class.after(unless: method_name) {}

          action_class.send(:define_method, method_name) do |*args|
            arguments = args
          end

          action.call

          expect(arguments).to be == [expected_result]
        end
        # rubocop:enable RSpec/ExampleLength
      end

      context 'when the conditional block returns true' do
        before(:example) do
          action_class.send(:define_method, method_name) { |_| true }
        end

        include_examples 'should not yield the block'

        wrap_context 'when the action has chained commands' do
          include_examples 'should not yield the block'
        end
      end

      context 'when the conditional block returns false' do
        before(:example) do
          action_class.send(:define_method, method_name) { |_| false }
        end

        include_examples 'should yield and return the last result'

        wrap_context 'when the action has chained commands' do
          include_examples 'should yield and return the last result'
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  describe '::before' do
    it 'should define the class method' do
      expect(action_class)
        .to respond_to(:before)
        .with(0).arguments
        .and_a_block
    end

    describe 'without a block' do
      it 'should raise an error' do
        expect { action_class.before }
          .to raise_error ArgumentError, 'must provide a block'
      end
    end

    describe 'with no arguments' do
      def define_hook(&block)
        action_class.before(&block)
      end

      it 'should return the result' do
        define_hook {}

        expect(action.call).to be expected_result
      end

      it 'should yield the initial result to the block' do
        expect do |block|
          define_hook(&block)

          action.call
        end
          .to yield_with_args(an_instance_of Ephesus::Core::Actions::Result)
      end

      it 'should evaluate the block in the context of the action instance' do
        context = nil

        define_hook { context = self }

        action.call

        expect(context).to be action
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should call the action with the yielded result' do
        yielded = nil
        called  = nil

        action_class.before { |result| yielded = result }

        allow(action).to receive(:process) do
          called = action.send(:result)
        end

        action.call

        expect(called).to be yielded
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
