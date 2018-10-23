# frozen_string_literal: true

require 'ephesus/core/immutable_store'
require 'ephesus/core/utils/dispatch_proxy'

RSpec.describe Ephesus::Core::Utils::DispatchProxy do
  subject(:instance) { described_class.new(dispatcher) }

  let(:dispatcher) do
    instance_double(Ephesus::Core::ImmutableStore, dispatch: true)
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#dispatch' do
    let(:action) { { type: 'spec.actions.example_action' } }

    it { expect(instance).to respond_to(:dispatch).with(1).argument }

    it 'should delegate to the dispatcher' do
      instance.dispatch(action)

      expect(dispatcher).to have_received(:dispatch).with(action)
    end
  end
end
