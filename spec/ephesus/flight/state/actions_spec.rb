# frozen_string_literal: true

require 'ephesus/flight/state/actions'

RSpec.describe Ephesus::Flight::State::Actions do
  include_examples 'should define constant',
    :GRANT_LANDING_CLEARANCE,
    'ephesus.flight.state.actions.grant_landing_clearance'

  include_examples 'should define constant',
    :GRANT_TAKEOFF_CLEARANCE,
    'ephesus.flight.state.actions.grant_takeoff_clearance'

  include_examples 'should define constant',
    :LAND,
    'ephesus.flight.state.actions.land'

  include_examples 'should define constant',
    :RADIO_OFF,
    'ephesus.flight.state.actions.radio_off'

  include_examples 'should define constant',
    :RADIO_ON,
    'ephesus.flight.state.actions.radio_on'

  include_examples 'should define constant',
    :TAKEOFF,
    'ephesus.flight.state.actions.takeoff'

  include_examples 'should define constant',
    :TAXI,
    'ephesus.flight.state.actions.taxi'

  include_examples 'should define constant',
    :UPDATE_SCORE,
    'ephesus.flight.state.actions.update_score'

  describe '::grant_landing_clearance' do
    let(:expected) do
      { type: described_class::GRANT_LANDING_CLEARANCE }
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:grant_landing_clearance)
        .with(0).arguments
    end

    it { expect(described_class.grant_landing_clearance).to be == expected }
  end

  describe '::grant_takeoff_clearance' do
    let(:expected) do
      { type: described_class::GRANT_TAKEOFF_CLEARANCE }
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:grant_takeoff_clearance)
        .with(0).arguments
    end

    it { expect(described_class.grant_takeoff_clearance).to be == expected }
  end

  describe '::land' do
    let(:expected) do
      { type: described_class::LAND }
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:land)
        .with(0).arguments
    end

    it { expect(described_class.land).to be == expected }
  end

  describe '::radio_off' do
    let(:expected) do
      { type: described_class::RADIO_OFF }
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:radio_off)
        .with(0).arguments
    end

    it { expect(described_class.radio_off).to be == expected }
  end

  describe '::radio_on' do
    let(:expected) do
      { type: described_class::RADIO_ON }
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:radio_on)
        .with(0).arguments
    end

    it { expect(described_class.radio_on).to be == expected }
  end

  describe '::takeoff' do
    let(:expected) do
      { type: described_class::TAKEOFF }
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:takeoff)
        .with(0).arguments
    end

    it { expect(described_class.takeoff).to be == expected }
  end

  describe '::taxi' do
    let(:destination) { 'tarmac' }
    let(:expected) do
      {
        destination: destination,
        type:        described_class::TAXI
      }
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:taxi)
        .with(0).arguments
        .and_keywords(:to)
    end

    it { expect(described_class.taxi to: destination).to be == expected }
  end

  describe '::update_score' do
    let(:amount) { 15 }
    let(:expected) do
      {
        amount: amount,
        type:   described_class::UPDATE_SCORE
      }
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:update_score)
        .with(0).arguments
        .and_keywords(:by)
    end

    it { expect(described_class.update_score by: amount).to be == expected }
  end
end
