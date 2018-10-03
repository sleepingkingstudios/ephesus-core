# frozen_string_literal: true

require 'ephesus/flight/events'

RSpec.describe Ephesus::Flight::Events do
  describe '::GrantLandingClearance' do
    let(:params) { {} }
    let(:event)  { described_class::GrantLandingClearance.new(params) }

    it { expect(described_class).to have_constant :GrantLandingClearance }

    it { expect(described_class::GrantLandingClearance).to be_a Class }

    it 'should be an Event subclass' do
      expect(described_class::GrantLandingClearance)
        .to be < Ephesus::Core::Event
    end
  end

  describe '::GrantTakeoffClearance' do
    let(:params) { {} }
    let(:event)  { described_class::GrantTakeoffClearance.new(params) }

    it { expect(described_class).to have_constant :GrantTakeoffClearance }

    it { expect(described_class::GrantTakeoffClearance).to be_a Class }

    it 'should be an Event subclass' do
      expect(described_class::GrantTakeoffClearance)
        .to be < Ephesus::Core::Event
    end
  end

  describe '::Land' do
    let(:params) { {} }
    let(:event)  { described_class::Land.new(params) }

    it { expect(described_class).to have_constant :Land }

    it { expect(described_class::Land).to be_a Class }

    it { expect(described_class::Land).to be < Ephesus::Core::Event }
  end

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

  describe '::Takeoff' do
    let(:params) { {} }
    let(:event)  { described_class::Takeoff.new(params) }

    it { expect(described_class).to have_constant :Takeoff }

    it { expect(described_class::Takeoff).to be_a Class }

    it { expect(described_class::Takeoff).to be < Ephesus::Core::Event }
  end

  describe '::Taxi' do
    let(:params) { { to: 'runway' } }
    let(:event)  { described_class::Taxi.new(params) }

    it { expect(described_class).to have_constant :Taxi }

    it { expect(described_class::Taxi).to be_a Class }

    it { expect(described_class::Taxi).to be < Ephesus::Core::Event }

    it { expect(event).to have_reader(:to).with_value(params[:to]) }
  end

  describe '::UpdateScore' do
    let(:params) { { by: 5 } }
    let(:event)  { described_class::UpdateScore.new(params) }

    it { expect(described_class).to have_constant :UpdateScore }

    it { expect(described_class::UpdateScore).to be_a Class }

    it { expect(described_class::UpdateScore).to be < Ephesus::Core::Event }

    it { expect(event).to have_reader(:by).with_value(params[:by]) }
  end
end
