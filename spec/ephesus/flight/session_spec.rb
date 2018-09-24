# frozen_string_literal: true

require 'ephesus/flight/application'
require 'ephesus/flight/session'

RSpec.describe Ephesus::Flight::Session do
  subject(:instance) { described_class.new(application) }

  let(:application) { Ephesus::Flight::Application.new }

  describe '#controller' do
    it 'should return the default controller' do
      expect(instance.controller)
        .to be_a Ephesus::Flight::Controllers::LandedController
    end
  end
end