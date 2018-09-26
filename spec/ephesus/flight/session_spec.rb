# frozen_string_literal: true

require 'ephesus/flight/application'
require 'ephesus/flight/session'

RSpec.describe Ephesus::Flight::Session do
  shared_context 'when the radio is on' do
    before(:example) do
      application.send :state=, application.state.put(:radio, true)
    end
  end

  shared_context 'when the state is flying' do
    before(:example) do
      application.send :state=, application.state.put(:landed, false)
    end
  end

  subject(:instance) { described_class.new(application) }

  let(:application) { Ephesus::Flight::Application.new }

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
