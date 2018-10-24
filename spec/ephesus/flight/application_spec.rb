# frozen_string_literal: true

require 'ephesus/core/event_dispatcher'
require 'ephesus/flight/application'

RSpec.describe Ephesus::Flight::Application do
  subject(:instance) { described_class.new }

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

  describe '#state' do
    it { expect(instance.state).to be_a Hamster::Hash }

    it { expect(instance.state).to be == initial_state }
  end

  describe '#store' do
    it { expect(instance.store).to be_a Ephesus::Flight::State::Store }

    it { expect(instance.store.state).to be == initial_state }
  end
end
