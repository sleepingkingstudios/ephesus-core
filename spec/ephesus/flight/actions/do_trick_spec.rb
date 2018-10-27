# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/utils/dispatch_proxy'
require 'ephesus/flight/actions/do_trick'

RSpec.describe Ephesus::Flight::Actions::DoTrick do
  subject(:instance) { described_class.new(state, dispatcher: dispatcher) }

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy, dispatch: true)
  end
  let(:state) { Hamster::Hash.new }

  describe '::properties' do
    let(:arguments) { [{ name: :trick, required: true }] }
    let(:expected)  { { arguments: arguments, keywords: {} } }

    it { expect(described_class.properties).to be == expected }
  end

  describe '::signature' do
    let(:signature) { described_class.signature }

    it { expect(signature).to be_a Ephesus::Core::Actions::Signature }

    it { expect(signature.action_class).to be described_class }
  end

  describe '#call' do
    let(:action) { Ephesus::Flight::State::Actions.update_score(by: amount) }

    describe 'with an invalid trick' do
      let(:trick)  { 'explode' }
      let(:result) { instance.call(trick) }
      let(:error) do
        {
          type:   :invalid,
          params: { trick: trick }
        }
      end

      it { expect(result.success?).to be false }

      it { expect(result.errors[:trick]).to include error }

      it 'should not dispatch an action' do
        instance.call(trick)

        expect(dispatcher).not_to have_received(:dispatch)
      end
    end

    describe 'with "barrel roll"' do
      let(:trick)  { 'barrel roll' }
      let(:amount) { 10 }
      let(:result) { instance.call(trick) }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch an UPDATE_SCORE action' do
        instance.call(trick)

        expect(dispatcher).to have_received(:dispatch).with(be == action)
      end
    end

    describe 'with "immelmann turn"' do
      let(:trick)  { 'immelmann turn' }
      let(:amount) { 30 }
      let(:result) { instance.call(trick) }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch an UPDATE_SCORE action' do
        instance.call(trick)

        expect(dispatcher).to have_received(:dispatch).with(be == action)
      end
    end

    describe 'with "loop"' do
      let(:trick)  { 'loop' }
      let(:amount) { 20 }
      let(:result) { instance.call(trick) }

      it { expect(result.success?).to be true }

      it { expect(result.errors).to be_empty }

      it 'should dispatch an UPDATE_SCORE action' do
        instance.call(trick)

        expect(dispatcher).to have_received(:dispatch).with(be == action)
      end
    end
  end
end
