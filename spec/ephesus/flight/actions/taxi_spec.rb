# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/event_dispatcher'
require 'ephesus/flight/actions/taxi'

RSpec.describe Ephesus::Flight::Actions::Taxi do
  subject(:instance) do
    described_class.new(state, event_dispatcher: event_dispatcher)
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:state)            { Hamster::Hash.new(location: 'hangar') }

  describe '::properties' do
    let(:keywords) { { to: { name: :to, required: true } } }
    let(:expected) { { arguments: [], keywords: keywords } }

    it { expect(described_class.properties).to be == expected }
  end

  describe '::signature' do
    let(:signature) { described_class.signature }

    it { expect(signature).to be_a Ephesus::Core::Actions::Signature }

    it { expect(signature.action_class).to be described_class }
  end

  describe '#call' do
    describe 'with an invalid destination' do
      let(:destination) { 'control_tower' }
      let(:result)      { instance.call(to: destination) }
      let(:error) do
        {
          type:   :invalid,
          params: { to: destination }
        }
      end

      it { expect(result.success?).to be false }

      it { expect(result.errors[:destination]).to include error }

      it 'should not dispatch an event' do
        allow(event_dispatcher).to receive(:dispatch_event)

        instance.call(to: destination)

        expect(event_dispatcher).not_to have_received(:dispatch_event)
      end
    end

    describe 'with the current location' do
      let(:destination) { 'hangar' }
      let(:result)      { instance.call(to: destination) }
      let(:error) do
        {
          type:   :already_at_destination,
          params: { to: destination }
        }
      end

      it { expect(result.success?).to be false }

      it { expect(result.errors[:destination]).to include error }

      it 'should not dispatch an event' do
        allow(event_dispatcher).to receive(:dispatch_event)

        instance.call(to: destination)

        expect(event_dispatcher).not_to have_received(:dispatch_event)
      end
    end

    describe 'with a valid destination' do
      let(:destination) { 'runway' }
      let(:result)      { instance.call(to: destination) }
      let(:event)       { Ephesus::Flight::Events::Taxi.new(to: destination) }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch a TAXI event' do
        allow(event_dispatcher).to receive(:dispatch_event)

        instance.call(to: destination)

        expect(event_dispatcher)
          .to have_received(:dispatch_event)
          .with(be == event)
      end
    end
  end
end
