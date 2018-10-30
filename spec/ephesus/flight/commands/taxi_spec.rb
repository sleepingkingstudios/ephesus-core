# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/commands/taxi'

RSpec.describe Ephesus::Flight::Commands::Taxi do
  subject(:instance) { described_class.new(state, dispatcher: dispatcher) }

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy, dispatch: true)
  end
  let(:state) { Hamster::Hash.new(location: 'hangar') }

  describe '::properties' do
    let(:keywords) { { to: { name: :to, required: true } } }
    let(:expected) { { arguments: [], keywords: keywords } }

    it { expect(described_class.properties).to be == expected }
  end

  describe '::signature' do
    let(:signature) { described_class.signature }

    it { expect(signature).to be_a Ephesus::Core::Commands::Signature }

    it { expect(signature.command_class).to be described_class }
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

      it 'should not dispatch an action' do
        instance.call(to: destination)

        expect(dispatcher).not_to have_received(:dispatch)
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

      it 'should not dispatch an action' do
        instance.call(to: destination)

        expect(dispatcher).not_to have_received(:dispatch)
      end
    end

    describe 'with a valid destination' do
      let(:destination) { 'runway' }
      let(:result)      { instance.call(to: destination) }
      let(:action) do
        Ephesus::Flight::State::Actions.taxi(to: destination)
      end

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch a TAXI action' do
        instance.call(to: destination)

        expect(dispatcher).to have_received(:dispatch).with(be == action)
      end
    end
  end
end
