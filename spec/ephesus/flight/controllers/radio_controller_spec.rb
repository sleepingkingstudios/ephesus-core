# frozen_string_literal: true

require 'hamster'

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
  let(:initial_state) { { landed: true, radio: true } }
  let(:state)         { Hamster::Hash.new(initial_state) }

  describe '#command?' do
    it { expect(instance.command? :do_something).to be false }

    it { expect(instance.command? :request_clearance).to be true }

    it { expect(instance.command? :turn_off_radio).to be true }
  end

  describe '#commands' do
    it { expect(instance.commands).not_to include :do_something }

    it { expect(instance.commands).to include :request_clearance }

    it { expect(instance.commands).to include :turn_off_radio }
  end

  describe '#available_commands' do
    it { expect(instance.available_commands).not_to have_key :do_something }

    include_examples 'should be available',
      :request_clearance,
      Ephesus::Flight::Commands::RequestClearance

    include_examples 'should be available',
      :turn_off_radio,
      Ephesus::Flight::Commands::RadioOff

    wrap_context 'when flying' do
      include_examples 'should be available',
        :request_clearance,
        Ephesus::Flight::Commands::RequestClearance

      wrap_context 'when landing clearance has been granted' do
        it 'should not include :request_clearance' do
          expect(instance.available_commands).not_to have_key :request_clearance
        end
      end
    end

    wrap_context 'when takeoff clearance has been granted' do
      it 'should not include :request_clearance' do
        expect(instance.available_commands).not_to have_key :request_clearance
      end
    end
  end

  describe '#request_clearance' do
    include_examples 'should define command',
      :request_clearance,
      Ephesus::Flight::Commands::RequestClearance
  end

  describe '#turn_off_radio' do
    include_examples 'should define command',
      :turn_off_radio,
      Ephesus::Flight::Commands::RadioOff
  end
end
