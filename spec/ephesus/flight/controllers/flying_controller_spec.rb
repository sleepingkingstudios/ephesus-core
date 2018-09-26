# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/event_dispatcher'
require 'ephesus/flight/controllers/flying_controller'

RSpec.describe Ephesus::Flight::Controllers::FlyingController do
  shared_examples 'should define action' do |action_name, action_class|
    let(:action) { instance.send(action_name) }

    it { expect(instance).to respond_to(action_name).with(0).arguments }

    it { expect(action).to be_a action_class }

    it { expect(action.event_dispatcher).to be event_dispatcher }

    it { expect(action.state).to be state }
  end

  subject(:instance) do
    described_class.new(state, event_dispatcher: event_dispatcher)
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:initial_state)    { {} }
  let(:state)            { Hamster::Hash.new(initial_state) }

  describe '#action?' do
    it { expect(instance.action? :do_something).to be false }

    it { expect(instance.action? :radio_tower).to be true }
  end

  describe '#actions' do
    it { expect(instance.actions).not_to include :do_something }

    it { expect(instance.actions).to include :radio_tower }
  end

  describe '#available_actions' do
    it { expect(instance.available_actions).not_to have_key :do_something }

    it { expect(instance.available_actions[:radio_tower]).to be == {} }
  end

  describe '#radio_tower' do
    include_examples 'should define action',
      :radio_tower,
      Ephesus::Flight::Actions::RadioOn
  end
end
