# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/flight/reducer'

RSpec.describe Ephesus::Flight::Reducer do
  let(:initial_state) { { landed: true, location: 'hangar' } }
  let(:application)   { Spec::ApplicationWithReducer.new }

  example_class 'Spec::ApplicationWithReducer',
    base_class: Ephesus::Core::Application \
  do |klass|
    klass.send :include, described_class

    hsh = initial_state
    klass.define_method(:initial_state) { hsh }
  end

  describe 'when a RADIO_ON event is dispatched' do
    let(:event) { Ephesus::Flight::Events::RadioOn.new }
    let(:expected) do
      initial_state.merge radio: true
    end

    it 'should update the state' do
      expect { application.event_dispatcher.dispatch_event event }
        .to change(application, :state)
        .to be == expected
    end
  end

  describe 'when a TAXI event is dispatched' do
    let(:destination) { 'runway' }
    let(:event)       { Ephesus::Flight::Events::Taxi.new to: destination }
    let(:expected) do
      initial_state.merge location: destination
    end

    it 'should update the state' do
      expect { application.event_dispatcher.dispatch_event event }
        .to change(application, :state)
        .to be == expected
    end
  end
end
