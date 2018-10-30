# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/controllers/flying_controller'

RSpec.describe Ephesus::Flight::Controllers::FlyingController do
  shared_context 'when landing clearance has been granted' do
    let(:initial_state) { super().merge landing_clearance: true }
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
  let(:initial_state) { {} }
  let(:state)         { Hamster::Hash.new(initial_state) }

  describe '#command?' do
    it { expect(instance.command? :do_something).to be false }

    it { expect(instance.command? :do_trick).to be true }

    it { expect(instance.command? :land).to be true }

    it { expect(instance.command? :radio_tower).to be true }
  end

  describe '#commands' do
    it { expect(instance.commands).not_to include :do_something }

    it { expect(instance.commands).to include :do_trick }

    it { expect(instance.commands).to include :land }

    it { expect(instance.commands).to include :radio_tower }
  end

  describe '#available_commands' do
    it { expect(instance.available_commands).not_to have_key :do_something }

    it { expect(instance.available_commands).not_to have_key :land }

    include_examples 'should be available',
      :do_trick,
      Ephesus::Flight::Commands::DoTrick

    include_examples 'should be available',
      :radio_tower,
      Ephesus::Flight::Commands::RadioOn

    wrap_context 'when landing clearance has been granted' do
      include_examples 'should be available',
        :land,
        Ephesus::Flight::Commands::Land
    end
  end

  describe '#do_trick' do
    include_examples 'should define command',
      :do_trick,
      Ephesus::Flight::Commands::DoTrick
  end

  describe '#land' do
    include_examples 'should define command',
      :land,
      Ephesus::Flight::Commands::Land
  end

  describe '#radio_tower' do
    include_examples 'should define command',
      :radio_tower,
      Ephesus::Flight::Commands::RadioOn
  end
end
