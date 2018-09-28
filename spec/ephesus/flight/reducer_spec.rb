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

  describe 'when a GRANT_LANDING_CLEARANCE event is dispatched' do
    let(:initial_state) { super().merge landed: false }
    let(:event)         { Ephesus::Flight::Events::GrantLandingClearance.new }
    let(:expected) do
      initial_state.merge landing_clearance: true
    end

    it 'should update the state' do
      expect { application.event_dispatcher.dispatch_event event }
        .to change(application, :state)
        .to be == expected
    end
  end

  describe 'when a GRANT_TAKEOFF_CLEARANCE event is dispatched' do
    let(:event) { Ephesus::Flight::Events::GrantTakeoffClearance.new }
    let(:expected) do
      initial_state.merge takeoff_clearance: true
    end

    it 'should update the state' do
      expect { application.event_dispatcher.dispatch_event event }
        .to change(application, :state)
        .to be == expected
    end
  end

  describe 'when a RADIO_OFF event is dispatched' do
    let(:initial_state) { super().merge radio: true }
    let(:event)         { Ephesus::Flight::Events::RadioOff.new }
    let(:expected) do
      initial_state.merge radio: false
    end

    it 'should update the state' do
      expect { application.event_dispatcher.dispatch_event event }
        .to change(application, :state)
        .to be == expected
    end
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

  describe 'when a TAKEOFF event is dispatched' do
    let(:initial_state) { super().merge takeoff_clearance: true }
    let(:event)         { Ephesus::Flight::Events::Takeoff.new }
    let(:expected) do
      initial_state
        .tap { |hsh| hsh.delete(:location) }
        .tap { |hsh| hsh.delete(:takeoff_clearance) }
        .merge(landed: false)
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
