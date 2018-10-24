# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/event_dispatcher'
require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/actions/request_clearance'

RSpec.describe Ephesus::Flight::Actions::RequestClearance do
  subject(:instance) do
    described_class.new(
      state,
      dispatcher:       dispatcher,
      event_dispatcher: event_dispatcher
    )
  end

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy, dispatch: true)
  end
  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:initial_state)    { {} }
  let(:state)            { Hamster::Hash.new(initial_state) }

  describe '::properties' do
    let(:expected) { { arguments: [], keywords: {} } }

    it { expect(described_class.properties).to be == expected }
  end

  describe '::signature' do
    let(:signature) { described_class.signature }

    it { expect(signature).to be_a Ephesus::Core::Actions::Signature }

    it { expect(signature.action_class).to be described_class }
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
