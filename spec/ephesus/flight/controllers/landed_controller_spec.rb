# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/controllers/landed_controller'

require 'support/examples/controller_examples'

RSpec.describe Ephesus::Flight::Controllers::LandedController do
  include Spec::Support::Examples::ControllerExamples

  shared_context 'when at the runway' do
    before(:example) { initial_state.update(location: 'runway') }
  end

  shared_context 'when at the tarmac' do
    before(:example) { initial_state.update(location: 'tarmac') }
  end

  shared_context 'when takeoff clearance has been granted' do
    before(:example) { initial_state.update(takeoff_clearance: true) }
  end

  subject(:instance) { described_class.new(state, dispatcher: dispatcher) }

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy)
  end
  let(:initial_state) { { location: 'hangar' } }
  let(:state)         { Hamster::Hash.new(initial_state) }

  describe '#available_commands' do
    it { expect(instance.available_commands).not_to have_key :do_something }

    it { expect(instance.available_commands).not_to have_key :take_off }

    include_examples 'should have available command',
      :radio_tower,
      Ephesus::Flight::Commands::RadioOn

    include_examples 'should have available command',
      :taxi,
      Ephesus::Flight::Commands::Taxi

    wrap_context 'when at the runway' do
      it { expect(instance.available_commands).not_to have_key :take_off }

      wrap_context 'when takeoff clearance has been granted' do
        include_examples 'should have available command',
          :take_off,
          Ephesus::Flight::Commands::Takeoff
      end
    end

    wrap_context 'when at the tarmac' do
      it { expect(instance.available_commands).not_to have_key :take_off }

      wrap_context 'when takeoff clearance has been granted' do
        it { expect(instance.available_commands).not_to have_key :take_off }
      end
    end

    wrap_context 'when takeoff clearance has been granted' do
      it { expect(instance.available_commands).not_to have_key :take_off }
    end
  end

  describe '#command?' do
    it { expect(instance.command? :do_something).to be false }

    it { expect(instance.command? :radio_tower).to be true }

    it { expect(instance.command? :take_off).to be true }

    it { expect(instance.command? :taxi).to be true }
  end

  describe '#commands' do
    it { expect(instance.commands).not_to include :do_something }

    it { expect(instance.commands).to include :radio_tower }

    it { expect(instance.commands).to include :take_off }

    it { expect(instance.commands).to include :taxi }
  end

  describe '#radio_tower' do
    include_examples 'should define command',
      :radio_tower,
      Ephesus::Flight::Commands::RadioOn
  end

  describe '#take_off' do
    include_examples 'should define command',
      :take_off,
      Ephesus::Flight::Commands::Takeoff
  end

  describe '#taxi' do
    include_examples 'should define command',
      :taxi,
      Ephesus::Flight::Commands::Taxi
  end
end
