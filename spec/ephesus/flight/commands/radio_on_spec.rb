# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/commands/radio_on'

RSpec.describe Ephesus::Flight::Commands::RadioOn do
  subject(:instance) { described_class.new(state, dispatcher: dispatcher) }

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy, dispatch: true)
  end
  let(:state) { Hamster::Hash.new }

  describe '::properties' do
    let(:expected) do
      {
        arguments:        [],
        description:      'Turn on the radio.',
        examples:         [],
        full_description: nil,
        keywords:         {}
      }
    end

    it { expect(described_class.properties).to be == expected }
  end

  describe '::signature' do
    let(:signature) { described_class.signature }

    it { expect(signature).to be_a Ephesus::Core::Commands::Signature }

    it { expect(signature.command_class).to be described_class }
  end

  describe '#call' do
    let(:result) { instance.call }
    let(:action) { Ephesus::Flight::State::Actions.radio_on }

    it { expect(result.success?).to be true }

    it { expect(result.errors).to be_empty }

    it 'should dispatch a RADIO_ON action' do
      instance.call

      expect(dispatcher).to have_received(:dispatch).with(be == action)
    end
  end
end
