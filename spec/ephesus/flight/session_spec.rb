# frozen_string_literal: true

require 'ephesus/flight/application'
require 'ephesus/flight/session'

RSpec.describe Ephesus::Flight::Session do
  shared_context 'when the radio is on' do
    let(:initial_state) { super().merge radio: true }
  end

  shared_context 'when the state is flying' do
    let(:initial_state) { super().merge landed: false }
  end

  subject(:instance) { described_class.new(application) }

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
  let(:application) { Ephesus::Flight::Application.new(state: initial_state) }

  describe '#controller' do
    it 'should return the default controller' do
      expect(instance.controller)
        .to be_a Ephesus::Flight::Controllers::LandedController
    end

    wrap_context 'when the radio is on' do
      it 'should return the radio controller' do
        expect(instance.controller)
          .to be_a Ephesus::Flight::Controllers::RadioController
      end
    end

    wrap_context 'when the state is flying' do
      it 'should return the flying controller' do
        expect(instance.controller)
          .to be_a Ephesus::Flight::Controllers::FlyingController
      end

      wrap_context 'when the radio is on' do
        it 'should return the radio controller' do
          expect(instance.controller)
            .to be_a Ephesus::Flight::Controllers::RadioController
        end
      end
    end
  end
end
