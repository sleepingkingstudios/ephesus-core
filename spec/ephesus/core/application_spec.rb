# frozen_string_literal: true

require 'bronze/collections/repository'

require 'ephesus/core/application'

RSpec.describe Ephesus::Core::Application do
  shared_context 'when a custom store is defined' do
    let(:store_initial_state) do
      {
        era:       :future,
        locations: ['Venus', 'the Moon', 'Mars'],
        genre:     'Space Romance'
      }
    end

    example_class 'Spec::ExampleStore', Ephesus::Core::ImmutableStore do |klass|
      state = store_initial_state

      klass.define_method(:initial_state) { Hamster::Hash.new(state) }
    end

    before(:example) do
      Spec::ExampleApplication.define_method(:build_store) do |state|
        Spec::ExampleStore.new(state)
      end
    end
  end

  shared_context 'when the application has an event dispatcher' do
    let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  end

  shared_context 'when the application has a repository' do
    let(:repository) { Spec::ExampleRepository.new }

    example_class 'Spec::ExampleRepository' do |klass|
      klass.send(:include, Bronze::Collections::Repository)
    end
  end

  shared_context 'when the #initial_state method is defined' do
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

  shared_context 'when an initial state is given' do
    let(:state) do
      {
        era:     :iron,
        faction: 'Silla',
        genre:   'Three Kingdoms'
      }
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
      repository:       repository,
      state:            state
    )
  end

  let(:event_dispatcher) { nil }
  let(:repository)       { nil }
  let(:state)            { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:event_dispatcher, :repository, :state)
    end

    describe 'with an event dispatcher' do
      let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
      let(:instance) do
        described_class.new(event_dispatcher: event_dispatcher)
      end

      it 'should inject the event dispatcher' do
        expect(instance.event_dispatcher).to be event_dispatcher
      end
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

        instance.event_dispatcher.dispatch_event(event)

        expect(called).to be true
      end
    end

    describe 'with a block with one argument' do
      it 'should call the block with the event' do
        args  = []
        block = ->(event) { args << event }

        instance.add_event_listener(event_type, &block)

        instance.event_dispatcher.dispatch_event(event)

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

        instance.event_dispatcher.dispatch_event(event)

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

        instance.event_dispatcher.dispatch_event(event)

        expect(arguments).to be == [event]
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#event_dispatcher' do
    include_examples 'should have reader',
      :event_dispatcher,
      -> { an_instance_of Ephesus::Core::EventDispatcher }

    wrap_context 'when the application has an event dispatcher' do
      it { expect(instance.event_dispatcher).to be event_dispatcher }
    end
  end

  describe '#repository' do
    include_examples 'should have reader', :repository, nil

    wrap_context 'when the application has a repository' do
      it { expect(instance.repository).to be repository }
    end
  end

  describe '#store' do
    include_examples 'should have reader',
      :store,
      -> { an_instance_of Ephesus::Core::ImmutableStore }

    it { expect(instance.store.state).to be_a Hamster::Hash }

    it { expect(instance.store.state).to be_empty }

    wrap_context 'when an initial state is given' do
      it { expect(instance.store.state).to be_a Hamster::Hash }

      it { expect(instance.store.state).to be == state }
    end

    wrap_context 'when the #initial_state method is defined' do
      include_context 'with an application subclass'

      it { expect(instance.store.state).to be_a Hamster::Hash }

      it { expect(instance.store.state).to be == initial_state }

      wrap_context 'when an initial state is given' do
        it { expect(instance.store.state).to be_a Hamster::Hash }

        it { expect(instance.store.state).to be == state }
      end
    end

    wrap_context 'when a custom store is defined' do
      include_context 'with an application subclass'

      it { expect(instance.store).to be_a Spec::ExampleStore }

      it { expect(instance.store.state).to be_a Hamster::Hash }

      it { expect(instance.store.state).to be == store_initial_state }

      wrap_context 'when an initial state is given' do
        it { expect(instance.store.state).to be_a Hamster::Hash }

        it { expect(instance.store.state).to be == state }
      end

      wrap_context 'when the #initial_state method is defined' do
        it { expect(instance.store.state).to be_a Hamster::Hash }

        it { expect(instance.store.state).to be == initial_state }

        wrap_context 'when an initial state is given' do
          it { expect(instance.store.state).to be_a Hamster::Hash }

          it { expect(instance.store.state).to be == state }
        end
      end
    end
  end
end
