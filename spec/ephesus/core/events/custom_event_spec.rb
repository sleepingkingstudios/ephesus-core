# frozen_string_literal: true

require 'ephesus/core/event'
require 'ephesus/core/events/custom_event'

RSpec.describe Ephesus::Core::Events::CustomEvent do
  subject(:instance) { described_class.new(event_data) }

  let(:described_class) { Spec::CustomEvent }
  let(:event_data)      { {} }

  example_class 'Spec::CustomEvent', base_class: Ephesus::Core::Event do |klass|
    # rubocop:disable RSpec/DescribedClass
    klass.include Ephesus::Core::Events::CustomEvent
    # rubocop:enable RSpec/DescribedClass
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  describe '#data' do
    include_examples 'should have reader', :data, {}

    context 'when the event has data' do
      let(:event_data) do
        {
          english:  'shortsword',
          german:   'einhänder',
          japanese: 'shoto'
        }
      end

      it { expect(instance.data).to be == event_data }
    end
  end
end
