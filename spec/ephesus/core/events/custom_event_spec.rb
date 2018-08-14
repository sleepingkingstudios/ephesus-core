# frozen_string_literal: true

require 'ephesus/core/event'
require 'ephesus/core/events/custom_event'

RSpec.describe Ephesus::Core::Events::CustomEvent do
  shared_context 'when the event has data' do
    let(:event_data) do
      {
        english:  'shortsword',
        german:   'einhänder',
        japanese: 'shoto'
      }
    end
  end

  shared_context 'when the event has an event type' do
    let(:event_types) do
      %w[
        spec.events.grandparent_event
        spec.events.parent_event
        spec.events.custom_event
      ]
    end

    before(:example) do
      types = event_types

      described_class.send(:define_method, :event_type)  { types.last }
      described_class.send(:define_method, :event_types) { types }

      described_class.send(:define_singleton_method, :event_types) { types }
    end
  end

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

  describe '::from_hash' do
    it { expect(described_class).to respond_to(:from_hash).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.from_hash(nil) }
          .to raise_error ArgumentError, 'argument must be a Hash'
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { described_class.from_hash(Object.new) }
          .to raise_error ArgumentError, 'argument must be a Hash'
      end
    end

    describe 'with an empty Hash' do
      it 'should raise an error' do
        expect { described_class.from_hash({}) }
          .to raise_error ArgumentError, 'missing key :event_types'
      end
    end

    describe 'with a Hash with event_types: nil' do
      it 'should raise an error' do
        expect { described_class.from_hash(event_types: nil) }
          .to raise_error ArgumentError, "event_types can't be nil"
      end
    end

    describe 'with a Hash with event_types: ""' do
      it 'should raise an error' do
        expect { described_class.from_hash(event_types: '') }
          .to raise_error ArgumentError, "event_types can't be empty"
      end
    end

    describe 'with a Hash with event_types: []' do
      it 'should raise an error' do
        expect { described_class.from_hash(event_types: []) }
          .to raise_error ArgumentError, "event_types can't be empty"
      end
    end

    describe 'with a Hash with one event type' do
      let(:hash)  { { event_types: 'spec.event_from_hash' } }
      let(:event) { described_class.from_hash(hash) }

      it { expect(event).to be_a described_class }

      it { expect(event.event_type).to be == hash[:event_types] }

      it { expect(event.event_types).to be == [hash[:event_types]] }

      it { expect(event.data).to be == {} }

      wrap_context 'when the event has data' do
        let(:hash) { super().merge(data: event_data) }

        it { expect(event.data).to be == event_data }
      end
    end

    describe 'with a Hash with many event types' do
      let(:event_types) do
        %w[
          spec.events.grandparent_event
          spec.events.parent_event
          spec.events.event_from_hash
        ]
      end
      let(:hash)  { { event_types: event_types } }
      let(:event) { described_class.from_hash(hash) }

      it { expect(event).to be_a described_class }

      it { expect(event.event_type).to be == hash[:event_types].last }

      it { expect(event.event_types).to be == hash[:event_types] }

      it { expect(event.data).to be == {} }

      wrap_context 'when the event has data' do
        let(:hash) { super().merge(data: event_data) }

        it { expect(event.data).to be == event_data }
      end
    end

    wrap_context 'when the event has an event type' do
      describe 'with an empty Hash' do
        it 'should raise an error' do
          expect { described_class.from_hash({}) }
            .to raise_error ArgumentError, 'missing key :event_types'
        end
      end

      describe 'with a Hash with event_types: nil' do
        it 'should raise an error' do
          expect { described_class.from_hash(event_types: nil) }
            .to raise_error ArgumentError, "event_types can't be nil"
        end
      end

      describe 'with a Hash with event_types: ""' do
        it 'should raise an error' do
          expect { described_class.from_hash(event_types: '') }
            .to raise_error ArgumentError, "event_types can't be empty"
        end
      end

      describe 'with a Hash with event_types: []' do
        it 'should raise an error' do
          expect { described_class.from_hash(event_types: []) }
            .to raise_error ArgumentError, "event_types can't be empty"
        end
      end

      describe 'with a Hash with one non-matching event type' do
        let(:hash) { { event_types: 'spec.other_event' } }
        let(:error_message) do
          "expected event types to be #{event_types.inspect}, but were " \
          "#{[hash[:event_types]]}"
        end

        it 'should raise an error' do
          expect { described_class.from_hash(hash) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with one matching event type' do
        let(:hash)  { { event_types: event_types.last } }
        let(:event) { described_class.from_hash(hash) }

        it { expect(event).to be_a described_class }

        it { expect(event.event_type).to be == event_types.last }

        it { expect(event.event_types).to be == event_types }

        it { expect(event.data).to be == {} }

        wrap_context 'when the event has data' do
          let(:hash) { super().merge(data: event_data) }

          it { expect(event.data).to be == event_data }
        end
      end

      describe 'with a Hash with many non-matching event types' do
        let(:other_types) do
          %w[
            spec.events.grandparent_event
            spec.events.parent_event
            spec.events.event_from_hash
          ]
        end
        let(:hash) { { event_types: other_types } }
        let(:error_message) do
          "expected event types to be #{event_types.inspect}, but were " \
          "#{hash[:event_types]}"
        end

        it 'should raise an error' do
          expect { described_class.from_hash(hash) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with a partially-matching event type' do
        let(:other_types) do
          %i[
            spec.events.grandparent_event
            spec.events.parent_event
            spec.events.event_from_hash
          ]
        end
        let(:hash) { { event_types: other_types } }
        let(:error_message) do
          "expected event types to be #{event_types.inspect}, but were " \
          "#{hash[:event_types]}"
        end

        it 'should raise an error' do
          expect { described_class.from_hash(hash) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with many matching event types' do
        let(:hash)  { { event_types: event_types } }
        let(:event) { described_class.from_hash(hash) }

        it { expect(event).to be_a described_class }

        it { expect(event.event_type).to be == event_types.last }

        it { expect(event.event_types).to be == event_types }

        it { expect(event.data).to be == {} }

        wrap_context 'when the event has data' do
          let(:hash) { super().merge(data: event_data) }

          it { expect(event.data).to be == event_data }
        end
      end
    end
  end

  describe '#data' do
    include_examples 'should have reader', :data, {}

    wrap_context 'when the event has data' do
      it { expect(instance.data).to be == event_data }
    end
  end
end
