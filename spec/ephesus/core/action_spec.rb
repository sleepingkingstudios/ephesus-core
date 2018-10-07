# frozen_string_literal: true

require 'bronze/collections/repository'
require 'bronze/entities/entity'
require 'hamster'

require 'ephesus/core/action'
require 'ephesus/core/event_dispatcher'

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

  shared_context 'when the action has a repository' do
    let(:repository) { Spec::ExampleRepository.new }

    example_class 'Spec::ExampleRepository' do |klass|
      klass.send(:include, Bronze::Collections::Repository)
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

  subject(:instance) do
    described_class.new(
      state,
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  let(:state)            { Hamster::Hash.new }
  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:event_dispatcher, :repository)
    end
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
          .to yield_with_args(an_instance_of Ephesus::Core::Actions::Result)
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

  describe '#build_result' do
    it { expect(instance).not_to respond_to(:build_result) }

    it 'should define the private method' do
      expect(instance)
        .to respond_to(:build_result, true)
        .with(0..1).arguments
        .and_any_keywords
    end

    it 'should return a result' do
      expect(instance.send :build_result).to be_a Ephesus::Core::Actions::Result
    end

    it { expect(instance.send(:build_result).value).to be nil }

    it { expect(instance.send(:build_result).errors).to be_a Bronze::Errors }

    it { expect(instance.send(:build_result).errors).to be_empty }

    describe 'with a value' do
      let(:value) { 'result value' }

      it { expect(instance.send(:build_result, value).value).to be value }
    end
  end

  describe '#dispatch_event' do
    let(:event_type) { 'spec.events.example_event' }
    let(:event)      { Ephesus::Core::Event.new(event_type) }

    it 'should define the method' do
      expect(instance).to respond_to(:dispatch_event).with(1).argument
    end

    it 'should delegate to the event dispatcher' do
      allow(event_dispatcher).to receive(:dispatch_event)

      instance.dispatch_event(event)

      expect(event_dispatcher).to have_received(:dispatch_event).with(event)
    end
  end

  describe '#event_dispatcher' do
    include_examples 'should have reader',
      :event_dispatcher,
      -> { event_dispatcher }
  end

  describe '#repository' do
    include_examples 'should have reader', :repository, nil

    wrap_context 'when the action has a repository' do
      it { expect(instance.repository).to be repository }
    end
  end

  describe '#state' do
    include_examples 'should have reader', :state, -> { state }
  end
end
