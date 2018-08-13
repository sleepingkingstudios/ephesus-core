# frozen_string_literal: true

require 'ephesus/core/action'

RSpec.describe Ephesus::Core::Action do
  shared_context 'when an action class is defined' do
    let(:described_class) { Spec::ExampleAction }
    let(:expected_result) { result }
    let(:result)          { Cuprum::Result.new 'first result' }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleAction', base_class: Ephesus::Core::Action
    # rubocop:enable RSpec/DescribedClass

    before(:example) do
      # rubocop:disable RSpec/SubjectStub
      allow(instance).to receive(:process).and_return(result)
      # rubocop:enable RSpec/SubjectStub
    end
  end

  shared_context 'when the action has chained commands' do
    let(:chained_command) { Cuprum::Command.new }
    let(:chained_result)  { Cuprum::Result.new 'chained result' }
    let(:expected_result) { chained_result }
    let(:instance) do
      super()
        .chain { 'second result' }
        .chain { 'third result' }
        .chain(chained_command)
    end

    before(:example) do
      allow(chained_command).to receive(:process).and_return(chained_result)
    end
  end

  subject(:instance) { described_class.new(session) }

  let(:session) { Spec::ExampleSession.new }

  example_class 'Spec::ExampleSession'

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '::after' do
    shared_examples 'should yield and return the last result' do
      it 'should return the result' do
        define_hook {}

        expect(instance.call).to be expected_result
      end

      it 'should yield the last result to the block' do
        expect do |block|
          define_hook(&block)

          instance.call
        end
          .to yield_with_args(expected_result)
      end
    end

    shared_examples 'should not yield the block' do
      it 'should not yield the block' do
        expect do |block|
          define_hook(&block)

          instance.call
        end
          .not_to yield_control
      end
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:after)
        .with(0..1).arguments
        .and_keywords(:if, :unless)
        .and_a_block
    end

    describe 'without a block' do
      it 'should raise an error' do
        expect { described_class.after }
          .to raise_error ArgumentError, 'must provide a block'
      end
    end

    describe 'with an invalid status' do
      it 'should raise an error' do
        expect { described_class.after(:on_fire) {} }
          .to raise_error ArgumentError, 'invalid result status :on_fire'
      end
    end

    describe 'with no arguments' do
      include_context 'when an action class is defined'

      def define_hook(&block)
        described_class.after(&block)
      end

      it 'should evaluate the block in the context of the action instance' do
        context = nil

        define_hook { context = self }

        instance.call

        expect(context).to be instance
      end

      include_examples 'should yield and return the last result'

      wrap_context 'when the action has chained commands' do
        include_examples 'should yield and return the last result'
      end
    end

    # rubocop:disable RSpec/NestedGroups
    describe 'with :success' do
      include_context 'when an action class is defined'

      def define_hook(&block)
        described_class.after(:success, &block)
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
      include_context 'when an action class is defined'

      def define_hook(&block)
        described_class.after(:failure, &block)
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
      include_context 'when an action class is defined'

      let(:conditional) { ->(_) {} }

      def define_hook(&block)
        described_class.after(if: conditional, &block)
      end

      context 'when the conditional block takes an argument' do
        it 'should yield the last result to the conditional block' do
          yielded     = nil
          conditional = ->(result) { yielded = result }

          described_class.after(if: conditional) {}

          instance.call

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
      include_context 'when an action class is defined'

      let(:method_name) { :conditional_method }

      def define_hook(&block)
        described_class.after(if: method_name, &block)
      end

      context 'when the action does not define the method' do
        it 'should raise an error when called' do
          define_hook {}

          expect { instance.call }
            .to raise_error NoMethodError,
              /undefined method `conditional_method'/
        end
      end

      context 'when the action defines the method' do
        # rubocop:disable RSpec/ExampleLength
        it 'should call the method with the last result' do
          arguments = nil

          described_class.after(if: method_name) {}

          described_class.send(:define_method, method_name) do |*args|
            arguments = args
          end

          instance.call

          expect(arguments).to be == [expected_result]
        end
        # rubocop:enable RSpec/ExampleLength
      end

      context 'when the conditional block returns true' do
        before(:example) do
          described_class.send(:define_method, method_name) { |_| true }
        end

        include_examples 'should yield and return the last result'

        wrap_context 'when the action has chained commands' do
          include_examples 'should yield and return the last result'
        end
      end

      context 'when the conditional block returns false' do
        before(:example) do
          described_class.send(:define_method, method_name) { |_| false }
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
      include_context 'when an action class is defined'

      let(:conditional) { ->(_) {} }

      def define_hook(&block)
        described_class.after(unless: conditional, &block)
      end

      context 'when the conditional block takes an argument' do
        it 'should yield the last result to the conditional block' do
          yielded     = nil
          conditional = ->(result) { yielded = result }

          described_class.after(unless: conditional) {}

          instance.call

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
      include_context 'when an action class is defined'

      let(:method_name) { :conditional_method }

      def define_hook(&block)
        described_class.after(unless: method_name, &block)
      end

      context 'when the action does not define the method' do
        it 'should raise an error when called' do
          define_hook {}

          expect { instance.call }
            .to raise_error NoMethodError,
              /undefined method `conditional_method'/
        end
      end

      context 'when the action defines the method' do
        # rubocop:disable RSpec/ExampleLength
        it 'should call the method with the last result' do
          arguments = nil

          described_class.after(unless: method_name) {}

          described_class.send(:define_method, method_name) do |*args|
            arguments = args
          end

          instance.call

          expect(arguments).to be == [expected_result]
        end
        # rubocop:enable RSpec/ExampleLength
      end

      context 'when the conditional block returns true' do
        before(:example) do
          described_class.send(:define_method, method_name) { |_| true }
        end

        include_examples 'should not yield the block'

        wrap_context 'when the action has chained commands' do
          include_examples 'should not yield the block'
        end
      end

      context 'when the conditional block returns false' do
        before(:example) do
          described_class.send(:define_method, method_name) { |_| false }
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
      expect(described_class)
        .to respond_to(:before)
        .with(0).arguments
        .and_a_block
    end

    describe 'without a block' do
      it 'should raise an error' do
        expect { described_class.before }
          .to raise_error ArgumentError, 'must provide a block'
      end
    end

    describe 'with no arguments' do
      include_context 'when an action class is defined'

      def define_hook(&block)
        described_class.before(&block)
      end

      it 'should return the result' do
        define_hook {}

        expect(instance.call).to be expected_result
      end

      it 'should yield the initial result to the block' do
        expect do |block|
          define_hook(&block)

          instance.call
        end
          .to yield_with_args(an_instance_of Cuprum::Result)
      end

      it 'should evaluate the block in the context of the action instance' do
        context = nil

        define_hook { context = self }

        instance.call

        expect(context).to be instance
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should call the action with the yielded result' do
        yielded = nil
        called  = nil

        described_class.before { |result| yielded = result }

        # rubocop:disable RSpec/SubjectStub
        allow(instance).to receive(:process) do
          called = instance.send(:result)
        end
        # rubocop:enable RSpec/SubjectStub

        instance.call

        expect(called).to be yielded
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#build_errors' do
    it 'should create an instance of Bronze::Errors' do
      # rubocop:disable RSpec/SubjectStub
      allow(instance).to receive(:process) do
        errors = instance.send(:result).errors

        expect(errors).to be_a Bronze::Errors
      end
      # rubocop:enable RSpec/SubjectStub

      instance.call
    end
  end

  describe '#session' do
    include_examples 'should have reader', :session, -> { session }
  end
end