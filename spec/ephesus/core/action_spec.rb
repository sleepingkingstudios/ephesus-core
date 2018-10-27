# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/action'
require 'ephesus/core/utils/dispatch_proxy'

RSpec.describe Ephesus::Core::Action do
  subject(:instance) do
    described_class.new(
      state,
      dispatcher: dispatcher,
      **options
    )
  end

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy, dispatch: true)
  end
  let(:state)   { Hamster::Hash.new }
  let(:options) { {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:dispatcher)
        .and_any_keywords
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

  describe '#dispatcher' do
    include_examples 'should have reader', :dispatcher, -> { dispatcher }
  end

  describe '#options' do
    include_examples 'should have reader', :options, {}

    context 'when the action is initialized with options' do
      let(:options) do
        {
          data:  [{}, {}, {}],
          flag:  true,
          param: 'value'
        }
      end

      it { expect(instance.options).to be == options }
    end
  end

  describe '#state' do
    include_examples 'should have reader', :state, -> { state }
  end
end
