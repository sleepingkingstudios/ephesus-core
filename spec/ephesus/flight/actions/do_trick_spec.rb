# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/event_dispatcher'
require 'ephesus/flight/actions/do_trick'

RSpec.describe Ephesus::Flight::Actions::DoTrick do
  subject(:instance) do
    described_class.new(state, event_dispatcher: event_dispatcher)
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:state)            { Hamster::Hash.new }

  describe '#call' do
    describe 'with an invalid trick' do
      let(:trick)  { 'explode' }
      let(:result) { instance.call(trick: trick) }
      let(:error) do
        {
          type:   :invalid,
          params: { trick: trick }
        }
      end

      it { expect(result.success?).to be false }

      it { expect(result.errors[:trick]).to include error }

      it 'should not dispatch an event' do
        allow(event_dispatcher).to receive(:dispatch_event)

        instance.call(trick: trick)

        expect(event_dispatcher).not_to have_received(:dispatch_event)
      end
    end

    describe 'with "barrel roll"' do
      let(:trick)  { 'barrel roll' }
      let(:result) { instance.call(trick: trick) }
      let(:event)  { Ephesus::Flight::Events::UpdateScore.new(by: 10) }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch an UPDATE_SCORE event' do
        allow(event_dispatcher).to receive(:dispatch_event)

        instance.call(trick: trick)

        expect(event_dispatcher)
          .to have_received(:dispatch_event)
          .with(be == event)
      end
    end

    describe 'with "immelmann turn"' do
      let(:trick)  { 'immelmann turn' }
      let(:result) { instance.call(trick: trick) }
      let(:event)  { Ephesus::Flight::Events::UpdateScore.new(by: 30) }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch an UPDATE_SCORE event' do
        allow(event_dispatcher).to receive(:dispatch_event)

        instance.call(trick: trick)

        expect(event_dispatcher)
          .to have_received(:dispatch_event)
          .with(be == event)
      end
    end

    describe 'with "loop"' do
      let(:trick)  { 'loop' }
      let(:result) { instance.call(trick: trick) }
      let(:event)  { Ephesus::Flight::Events::UpdateScore.new(by: 20) }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch an UPDATE_SCORE event' do
        allow(event_dispatcher).to receive(:dispatch_event)

        instance.call(trick: trick)

        expect(event_dispatcher)
          .to have_received(:dispatch_event)
          .with(be == event)
      end
    end
  end
end
