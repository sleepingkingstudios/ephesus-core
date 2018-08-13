# frozen_string_literal: true

require 'ephesus/core/event'

RSpec.describe Ephesus::Core::Event do
  shared_context 'when the event has data' do
    let(:event_data) do
      {
        english:  'shortsword',
        german:   'einhänder',
        japanese: 'shoto'
      }
    end
  end

  subject(:instance) { described_class.new(event_type, **event_data) }

  let(:event_type) { 'example_event' }
  let(:event_data) { {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_any_keywords
    end
  end

  describe '::keys' do
    include_examples 'should have class reader', :keys, -> { be == Set.new }
  end

  describe '#data' do
    include_examples 'should have reader', :data, -> { event_data }

    wrap_context 'when the event has data' do
      it { expect(instance.data).to be == event_data }
    end
  end

  describe '#event_type' do
    include_examples 'should have reader', :event_type, -> { event_type }
  end
end
