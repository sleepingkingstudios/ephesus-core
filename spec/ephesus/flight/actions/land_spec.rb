# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/event_dispatcher'
require 'ephesus/flight/actions/land'

RSpec.describe Ephesus::Flight::Actions::Land do
  subject(:instance) do
    described_class.new(state, event_dispatcher: event_dispatcher)
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:state)            { Hamster::Hash.new }

  describe '#call' do
    let(:result) { instance.call }
    let(:event)  { Ephesus::Flight::Events::Land.new }

    it { expect(result.success?).to be true }

    it { expect(result.errors).to be_empty }

    it 'should dispatch a LAND event' do
      allow(event_dispatcher).to receive(:dispatch_event)

      instance.call

      expect(event_dispatcher)
        .to have_received(:dispatch_event)
        .with(be == event)
    end
  end
end
