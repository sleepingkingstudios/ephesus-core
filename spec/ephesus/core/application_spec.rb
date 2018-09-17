# frozen_string_literal: true

require 'bronze/entities/entity'

require 'ephesus/core/application'

RSpec.describe Ephesus::Core::Application do
  shared_context 'when the application has a repository' do
    let(:repository) { Spec::ExampleRepository.new }

    example_class 'Spec::ExampleRepository' do |klass|
      klass.send(:include, Bronze::Collections::Repository)
    end
  end

  shared_context 'when the initial state is defined' do
    include_context 'with an application subclass'

    let(:initial_state) do
      {
        era:      :renaissance,
        firearms: false,
        genre:    'High Fantasy'
      }
    end

    before(:example) do
      hsh = initial_state

      Spec::ExampleApplication.define_method(:initial_state) { hsh }
    end
  end

  shared_context 'with an application subclass' do
    let(:described_class) { Spec::ExampleApplication }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleApplication',
      base_class: Ephesus::Core::Application
    # rubocop:enable RSpec/DescribedClass
  end

  subject(:instance) do
    described_class.new(
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:event_dispatcher, :repository)
    end
  end

  describe '#add_event_listener' do
    let(:event_type) { 'spec.events.custom_event' }
    let(:event)      { Ephesus::Core::Event.new(event_type) }

    it 'should define the method' do
      expect(instance)
        .to respond_to(:add_event_listener)
        .with(1..2).arguments
        .and_a_block
    end

    describe 'with no definition' do
      let(:error_message) do
        'listener must be a method name or a block'
      end

      it 'should raise an error' do
        expect { instance.add_event_listener(event_type) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block with no arguments' do
      it 'should call the block with no arguments' do
        called = false
        block  = -> { called = true }

        instance.add_event_listener(event_type, &block)

        event_dispatcher.dispatch_event(event)

        expect(called).to be true
      end
    end

    describe 'with a block with one argument' do
      it 'should call the block with the event' do
        args  = []
        block = ->(event) { args << event }

        instance.add_event_listener(event_type, &block)

        event_dispatcher.dispatch_event(event)

        expect(args).to contain_exactly(event)
      end
    end

    describe 'with the name of an undefined method' do
      let(:method_name) { :custom_event_handler }
      let(:error_message) do
        "undefined method `#{method_name}' for class `#{described_class}'"
      end

      it 'should raise an error' do
        expect { instance.add_event_listener(event_type, method_name) }
          .to raise_error NameError, error_message
      end
    end

    describe 'with the name of a method with no arguments' do
      let(:method_name) { :custom_event_handler }

      it 'should call the method with no arguments' do
        called = false

        instance.define_singleton_method(method_name) { called = true }

        instance.add_event_listener(event_type, method_name)

        event_dispatcher.dispatch_event(event)

        expect(called).to be true
      end
    end

    describe 'with the name of a method with one argument' do
      let(:method_name) { :custom_event_handler }

      # rubocop:disable RSpec/ExampleLength
      it 'should call the method with the event' do
        arguments = []

        instance.define_singleton_method(method_name) do |*args|
          arguments = args
        end

        instance.add_event_listener(event_type, method_name)

        event_dispatcher.dispatch_event(event)

        expect(arguments).to be == [event]
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#event_dispatcher' do
    include_examples 'should have reader',
      :event_dispatcher,
      -> { event_dispatcher }
  end

  describe '#repository' do
    include_examples 'should have reader', :repository, nil

    wrap_context 'when the application has a repository' do
      it { expect(instance.repository).to be repository }
    end
  end

  describe '#state' do
    include_examples 'should have reader', :state

    it { expect(instance.state).to be_a Hamster::Hash }

    it { expect(instance.state).to be_empty }

    wrap_context 'when the initial state is defined' do
      it { expect(instance.state).to be_a Hamster::Hash }

      it { expect(instance.state).to be == initial_state }
    end
  end
end
