# frozen_string_literal: true

require 'bronze/collections/repository'
require 'bronze/entities/entity'
require 'hamster'

require 'ephesus/core/action'
require 'ephesus/core/event_dispatcher'
require 'ephesus/core/utils/dispatch_proxy'

RSpec.describe Ephesus::Core::Action do
  shared_context 'when the action has a repository' do
    let(:repository) { Spec::ExampleRepository.new }

    example_class 'Spec::ExampleRepository' do |klass|
      klass.send(:include, Bronze::Collections::Repository)
    end
  end

  subject(:instance) do
    described_class.new(
      state,
      dispatcher:       dispatcher,
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy, dispatch: true)
  end
  let(:state)            { Hamster::Hash.new }
  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:dispatcher, :event_dispatcher, :repository)
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

  describe '#dispatch' do
    let(:action) { { type: 'spec.actions.example_action' } }

    it { expect(instance).to respond_to(:dispatch).with(1).argument }

    it 'should delegate to the dispatcher' do
      instance.dispatch(action)

      expect(dispatcher).to have_received(:dispatch).with(action)
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

  describe '#dispatcher' do
    include_examples 'should have reader', :dispatcher, -> { dispatcher }
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
