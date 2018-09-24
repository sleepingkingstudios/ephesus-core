# frozen_string_literal: true

require 'ephesus/core/event_dispatcher'
require 'ephesus/flight/application'

RSpec.describe Ephesus::Flight::Application do
  subject(:instance) { described_class.new }

  let(:initial_state) do
    {
      landed:   true,
      location: 'hangar'
    }
  end

  it { expect(described_class).to be < Ephesus::Flight::Reducer }

  describe '#state' do
    it { expect(instance.state).to be_a Hamster::Hash }

    it { expect(instance.state).to be == initial_state }
  end
end
