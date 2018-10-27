# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/controllers/flying_controller'

RSpec.describe Ephesus::Flight::Controllers::FlyingController do
  shared_context 'when landing clearance has been granted' do
    let(:initial_state) { super().merge landing_clearance: true }
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

  subject(:instance) { described_class.new(state, dispatcher: dispatcher) }

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy)
  end
  let(:initial_state) { {} }
  let(:state)         { Hamster::Hash.new(initial_state) }

  describe '#action?' do
    it { expect(instance.action? :do_something).to be false }

    it { expect(instance.action? :do_trick).to be true }

    it { expect(instance.action? :land).to be true }

    it { expect(instance.action? :radio_tower).to be true }
  end

  describe '#actions' do
    it { expect(instance.actions).not_to include :do_something }

    it { expect(instance.actions).to include :do_trick }

    it { expect(instance.actions).to include :land }

    it { expect(instance.actions).to include :radio_tower }
  end

  describe '#available_actions' do
    it { expect(instance.available_actions).not_to have_key :do_something }

    it { expect(instance.available_actions).not_to have_key :land }

    include_examples 'should be available',
      :do_trick,
      Ephesus::Flight::Actions::DoTrick

    include_examples 'should be available',
      :radio_tower,
      Ephesus::Flight::Actions::RadioOn

    wrap_context 'when landing clearance has been granted' do
      include_examples 'should be available',
        :land,
        Ephesus::Flight::Actions::Land
    end
  end

  describe '#do_trick' do
    include_examples 'should define action',
      :do_trick,
      Ephesus::Flight::Actions::DoTrick
  end

  describe '#land' do
    include_examples 'should define action',
      :land,
      Ephesus::Flight::Actions::Land
  end

  describe '#radio_tower' do
    include_examples 'should define action',
      :radio_tower,
      Ephesus::Flight::Actions::RadioOn
  end
end
