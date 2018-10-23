# frozen_string_literal: true

require 'ephesus/flight/state/actions'
require 'ephesus/flight/state/reducer'
require 'ephesus/flight/state/store'

RSpec.describe Ephesus::Flight::State::Reducer do
  shared_context 'when the state is flying' do
    before(:example) do
      initial_state.update(
        landed:            false,
        landing_clearance: false,
        location:          nil
      )
    end
  end

  shared_context 'when the state is landed' do
    before(:example) do
      initial_state.update(
        landed:            true,
        location:          'hangar',
        takeoff_clearance: false
      )
    end
  end

  let(:initial_state) { {} }
  let(:store)         { Ephesus::Flight::State::Store.new(initial_state) }

  context 'when the store dispatches GRANT_LANDING_CLEARANCE' do
    include_context 'when the state is flying'

    let(:expected) { initial_state.merge(landing_clearance: true) }
    let(:action) do
      Ephesus::Flight::State::Actions.grant_landing_clearance
    end

    it 'should update the state' do
      expect { store.dispatch(action) }
        .to change(store, :state)
        .to be == expected
    end
  end

  context 'when the store dispatches GRANT_TAKEOFF_CLEARANCE' do
    include_context 'when the state is landed'

    let(:expected) { initial_state.merge(takeoff_clearance: true) }
    let(:action) do
      Ephesus::Flight::State::Actions.grant_takeoff_clearance
    end

    it 'should update the state' do
      expect { store.dispatch(action) }
        .to change(store, :state)
        .to be == expected
    end
  end

  context 'when the store dispatches LAND' do
    include_context 'when the state is flying'

    before(:example) { initial_state.update(landing_clearance: true) }

    let(:expected) do
      initial_state.merge(
        landed:            true,
        landing_clearance: false,
        location:          'runway'
      )
    end
    let(:action) { Ephesus::Flight::State::Actions.land }

    it 'should update the state' do
      expect { store.dispatch(action) }
        .to change(store, :state)
        .to be == expected
    end
  end

  context 'when the store dispatches RADIO_OFF' do
    let(:expected) do
      initial_state.merge(radio: false)
    end
    let(:action) { Ephesus::Flight::State::Actions.radio_off }

    before(:example) { initial_state.merge(radio: true) }

    it 'should update the state' do
      expect { store.dispatch(action) }
        .to change(store, :state)
        .to be == expected
    end
  end

  context 'when the store dispatches RADIO_ON' do
    let(:expected) do
      initial_state.merge(radio: true)
    end
    let(:action) { Ephesus::Flight::State::Actions.radio_on }

    before(:example) { initial_state.merge(radio: false) }

    it 'should update the state' do
      expect { store.dispatch(action) }
        .to change(store, :state)
        .to be == expected
    end
  end

  context 'when the store dispatches TAKEOFF' do
    include_context 'when the state is landed'

    before(:example) { initial_state.update(takeoff_clearance: true) }

    let(:expected) do
      initial_state.merge(
        landed:            false,
        location:          nil,
        takeoff_clearance: false
      )
    end
    let(:action) { Ephesus::Flight::State::Actions.takeoff }

    it 'should update the state' do
      expect { store.dispatch(action) }
        .to change(store, :state)
        .to be == expected
    end
  end

  context 'when the store dispatches TAXI' do
    include_context 'when the state is landed'

    let(:destination) { 'tarmac' }
    let(:expected) do
      initial_state.merge(location: destination)
    end
    let(:action) { Ephesus::Flight::State::Actions.taxi to: destination }

    it 'should update the state' do
      expect { store.dispatch(action) }
        .to change(store, :state)
        .to be == expected
    end
  end

  context 'when the store dispatches UPDATE_SCORE' do
    include_context 'when the state is flying'

    let(:amount)   { 15 }
    let(:expected) { initial_state.merge(score: 40) }
    let(:action)   { Ephesus::Flight::State::Actions.update_score by: amount }

    before(:example) { initial_state.update(score: 25) }

    it 'should update the state' do
      expect { store.dispatch(action) }
        .to change(store, :state)
        .to be == expected
    end
  end
end
