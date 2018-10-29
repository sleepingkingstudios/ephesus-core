# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/controllers/landed_controller'

RSpec.describe Ephesus::Flight::Controllers::LandedController do
  shared_context 'when at the runway' do
    before(:example) { initial_state.update(location: 'runway') }
  end

  shared_context 'when at the tarmac' do
    before(:example) { initial_state.update(location: 'tarmac') }
  end

  shared_context 'when takeoff clearance has been granted' do
    before(:example) { initial_state.update(takeoff_clearance: true) }
  end

  shared_examples 'should be available' do |command_name, command_class|
    it 'should return the command properties' do
      expect(instance.available_commands[command_name])
        .to be == command_class.properties
    end
  end

  shared_examples 'should define command' do |command_name, command_class|
    let(:command) { instance.send(command_name) }

    it { expect(instance).to respond_to(command_name).with(0).arguments }

    it { expect(command).to be_a command_class }

    it { expect(command.state).to be state }
  end

  subject(:instance) { described_class.new(state, dispatcher: dispatcher) }

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy)
  end
  let(:initial_state) { { location: 'hangar' } }
  let(:state)         { Hamster::Hash.new(initial_state) }

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

  describe '#available_commands' do
    it { expect(instance.available_commands).not_to have_key :do_something }

    it { expect(instance.available_commands).not_to have_key :take_off }

    include_examples 'should be available',
      :radio_tower,
      Ephesus::Flight::Commands::RadioOn

    include_examples 'should be available',
      :taxi,
      Ephesus::Flight::Commands::Taxi

    wrap_context 'when at the runway' do
      it { expect(instance.available_commands).not_to have_key :take_off }

      wrap_context 'when takeoff clearance has been granted' do
        include_examples 'should be available',
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
