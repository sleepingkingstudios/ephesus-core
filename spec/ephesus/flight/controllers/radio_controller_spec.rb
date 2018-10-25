# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/event_dispatcher'
require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/controllers/radio_controller'

RSpec.describe Ephesus::Flight::Controllers::RadioController do
  shared_context 'when flying' do
    let(:initial_state) { super().merge landed: false }
  end

  shared_context 'when landing clearance has been granted' do
    let(:initial_state) { super().merge landing_clearance: true }
  end

  shared_context 'when takeoff clearance has been granted' do
    let(:initial_state) { super().merge takeoff_clearance: true }
  end

  shared_examples 'should be available' do |action_name, action_class|
    it 'should return the action properties' do
      expect(instance.available_actions[action_name])
        .to be == action_class.properties
    end
  end

  shared_examples 'should define action' do |action_name, action_class|
    let(:action) { instance.send(action_name) }

    it { expect(instance).to respond_to(action_name).with(0).arguments }

    it { expect(action).to be_a action_class }

    it { expect(action.state).to be state }
  end

  subject(:instance) do
    described_class.new(
      state,
      dispatcher: dispatcher,
      event_dispatcher: event_dispatcher
    )
  end

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy)
  end
  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:initial_state)    { { landed: true, radio: true } }
  let(:state)            { Hamster::Hash.new(initial_state) }

  describe '#action?' do
    it { expect(instance.action? :do_something).to be false }

    it { expect(instance.action? :request_clearance).to be true }

    it { expect(instance.action? :turn_off_radio).to be true }
  end

  describe '#actions' do
    it { expect(instance.actions).not_to include :do_something }

    it { expect(instance.actions).to include :request_clearance }

    it { expect(instance.actions).to include :turn_off_radio }
  end

  describe '#available_actions' do
    it { expect(instance.available_actions).not_to have_key :do_something }

    include_examples 'should be available',
      :request_clearance,
      Ephesus::Flight::Actions::RequestClearance

    include_examples 'should be available',
      :turn_off_radio,
      Ephesus::Flight::Actions::RadioOff

    wrap_context 'when flying' do
      include_examples 'should be available',
        :request_clearance,
        Ephesus::Flight::Actions::RequestClearance

      wrap_context 'when landing clearance has been granted' do
        it 'should not include :request_clearance' do
          expect(instance.available_actions).not_to have_key :request_clearance
        end
      end
    end

    wrap_context 'when takeoff clearance has been granted' do
      it 'should not include :request_clearance' do
        expect(instance.available_actions).not_to have_key :request_clearance
      end
    end
  end

  describe '#request_clearance' do
    include_examples 'should define action',
      :request_clearance,
      Ephesus::Flight::Actions::RequestClearance
  end

  describe '#turn_off_radio' do
    include_examples 'should define action',
      :turn_off_radio,
      Ephesus::Flight::Actions::RadioOff
  end
end
