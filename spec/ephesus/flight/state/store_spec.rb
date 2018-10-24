# frozen_string_literal: true

require 'ephesus/flight/state/store'

RSpec.describe Ephesus::Flight::State::Store do
  subject(:instance) { described_class.new }

  it { expect(described_class).to be < Ephesus::Core::ImmutableStore }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '#state' do
    let(:initial_state) do
      {
        landed:            true,
        landing_clearance: false,
        location:          'hangar',
        radio:             false,
        score:             0,
        takeoff_clearance: false
      }
    end

    include_examples 'should have reader', :state

    it { expect(instance.state).to be_a Hamster::Hash }

    it { expect(instance.state).to be == initial_state }

    context 'when initialized with a state' do
      let(:state) do
        {
          landed:            false,
          landing_clearance: true,
          location:          nil,
          radio:             true,
          score:             25,
          takeoff_clearance: false
        }
      end
      let(:instance) { described_class.new(state) }

      it { expect(instance.state).to be_a Hamster::Hash }

      it { expect(instance.state).to be == state }
    end
  end
end
