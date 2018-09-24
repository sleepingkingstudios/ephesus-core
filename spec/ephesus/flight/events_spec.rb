# frozen_string_literal: true

require 'ephesus/flight/events'

RSpec.describe Ephesus::Flight::Events do
  describe '::RadioOff' do
    let(:params) { {} }
    let(:event)  { described_class::RadioOff.new(params) }

    it { expect(described_class).to have_constant :RadioOff }

    it { expect(described_class::RadioOff).to be_a Class }

    it { expect(described_class::RadioOff).to be < Ephesus::Core::Event }
  end

  describe '::RadioOn' do
    let(:params) { {} }
    let(:event)  { described_class::RadioOn.new(params) }

    it { expect(described_class).to have_constant :RadioOn }

    it { expect(described_class::RadioOn).to be_a Class }

    it { expect(described_class::RadioOn).to be < Ephesus::Core::Event }
  end

  describe '::Taxi' do
    let(:params) { { to: 'runway' } }
    let(:event)  { described_class::Taxi.new(params) }

    it { expect(described_class).to have_constant :Taxi }

    it { expect(described_class::Taxi).to be_a Class }

    it { expect(described_class::Taxi).to be < Ephesus::Core::Event }

    it { expect(event).to have_reader(:to).with_value(params[:to]) }
  end
end
