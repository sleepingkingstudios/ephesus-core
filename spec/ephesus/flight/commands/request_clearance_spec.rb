# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/commands/request_clearance'

RSpec.describe Ephesus::Flight::Commands::RequestClearance do
  subject(:instance) { described_class.new(state, dispatcher: dispatcher) }

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy, dispatch: true)
  end
  let(:initial_state) { {} }
  let(:state)         { Hamster::Hash.new(initial_state) }

  describe '::properties' do
    let(:examples) do
      [
        {
          command:     'request clearance',
          description: 'Request takeoff clearance.',
          header:      'When Landed'
        },
        {
          command:     'request clearance',
          description: 'Request landing clearance.',
          header:      'When Flying'
        }
      ]
    end
    let(:full_description) do
      <<~DESCRIPTION
        Contact the control tower.

        If you are currently on the ground, request clearance to take off.

        If you are currently flying, request clearance to land.
      DESCRIPTION
    end
    let(:expected) do
      {
        arguments:        [],
        description:      'Request permission to take off or land.',
        examples:         examples,
        full_description: full_description,
        keywords:         {}
      }
    end

    it { expect(described_class.properties).to be == expected }
  end

  describe '::signature' do
    let(:signature) { described_class.signature }

    it { expect(signature).to be_a Ephesus::Core::Commands::Signature }

    it { expect(signature.command_class).to be described_class }
  end

  describe '#call' do
    context 'when the state is flying' do
      let(:initial_state) do
        super().merge landed: false
      end
      let(:result) { instance.call }
      let(:action) { Ephesus::Flight::State::Actions.grant_landing_clearance }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch a GRANT_LANDING_CLEARANCE action' do
        instance.call

        expect(dispatcher)
          .to have_received(:dispatch)
          .with(be == action)
      end
    end

    context 'when the state is landed' do
      let(:initial_state) do
        super().merge landed: true
      end

      let(:result) { instance.call }
      let(:action) { Ephesus::Flight::State::Actions.grant_takeoff_clearance }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch a GRANT_TAKEOFF_CLEARANCE action' do
        instance.call

        expect(dispatcher)
          .to have_received(:dispatch)
          .with(be == action)
      end
    end
  end
end
