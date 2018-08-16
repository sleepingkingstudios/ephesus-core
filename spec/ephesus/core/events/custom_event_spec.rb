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

  shared_context 'with a custom event subclass with defined event types' do
    let(:described_class) { Spec::CustomEventWithTypes }
    let(:event_types) do
      %w[
        spec.events.grandparent_event
        spec.events.parent_event
        spec.events.custom_event
      ]
    end

    example_class 'Spec::CustomEventWithTypes',
      base_class: Ephesus::Core::Event \
    do |klass|
      types = event_types

      # rubocop:disable RSpec/DescribedClass
      klass.send(:include, Ephesus::Core::Events::CustomEvent)
      # rubocop:enable RSpec/DescribedClass

      klass.send(:define_singleton_method, :event_types) do
        super() + types
      end
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
      let(:hash)  { {} }
      let(:event) { described_class.from_hash(hash) }

      it { expect(event).to be_a described_class }

      it { expect(event.event_type).to be == Ephesus::Core::Event::TYPE }

      it { expect(event.event_types).to be == [Ephesus::Core::Event::TYPE] }

      it { expect(event.data).to be == {} }

      wrap_context 'when the event has data' do
        let(:hash) { super().merge(data: event_data) }

        it { expect(event.data).to be == event_data }
      end
    end

    describe 'with a Hash with event_types: nil' do
      let(:error_message) do
        'invalid key event_types - expected Array, was nil'
      end

      it 'should raise an error' do
        expect { described_class.from_hash(event_types: nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a Hash with event_types: ""' do
      let(:error_message) do
        'invalid key event_types - expected Array, was ""'
      end

      it 'should raise an error' do
        expect { described_class.from_hash(event_types: '') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a Hash with event_types: []' do
      let(:hash)  { { event_types: [] } }
      let(:event) { described_class.from_hash(hash) }

      it { expect(event).to be_a described_class }

      it { expect(event.event_type).to be == Ephesus::Core::Event::TYPE }

      it { expect(event.event_types).to be == [Ephesus::Core::Event::TYPE] }

      it { expect(event.data).to be == {} }

      wrap_context 'when the event has data' do
        let(:hash) { super().merge(data: event_data) }

        it { expect(event.data).to be == event_data }
      end
    end

    describe 'with a Hash with a non-matching event type' do
      let(:expected_types) { [Ephesus::Core::Event::TYPE] }
      let(:hash)           { { event_types: ['spec.other_event'] } }
      let(:error_message) do
        "expected event types to be #{expected_types.inspect}, but were " \
        "#{hash[:event_types]}"
      end

      it 'should raise an error' do
        expect { described_class.from_hash(hash) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a Hash with a matching event type' do
      let(:expected_types) { [Ephesus::Core::Event::TYPE] }
      let(:hash)           { { event_types: [Ephesus::Core::Event::TYPE] } }
      let(:event)          { described_class.from_hash(hash) }

      it { expect(event).to be_a described_class }

      it { expect(event.event_type).to be == expected_types.last }

      it { expect(event.event_types).to be == expected_types }

      it { expect(event.data).to be == {} }

      wrap_context 'when the event has data' do
        let(:hash) { super().merge(data: event_data) }

        it { expect(event.data).to be == event_data }
      end
    end

    wrap_context 'with a custom event subclass with defined event types' do
      describe 'with an empty Hash' do
        let(:expected_types) { [Ephesus::Core::Event::TYPE, *event_types] }
        let(:hash)           { {} }
        let(:event)          { described_class.from_hash(hash) }

        it { expect(event).to be_a described_class }

        it { expect(event.event_type).to be == expected_types.last }

        it { expect(event.event_types).to be == expected_types }

        it { expect(event.data).to be == {} }

        wrap_context 'when the event has data' do
          let(:hash) { super().merge(data: event_data) }

          it { expect(event.data).to be == event_data }
        end
      end

      describe 'with a Hash with event_types: nil' do
        let(:error_message) do
          'invalid key event_types - expected Array, was nil'
        end

        it 'should raise an error' do
          expect { described_class.from_hash(event_types: nil) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with event_types: ""' do
        let(:error_message) do
          'invalid key event_types - expected Array, was ""'
        end

        it 'should raise an error' do
          expect { described_class.from_hash(event_types: '') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with event_types: []' do
        let(:expected_types) { [Ephesus::Core::Event::TYPE, *event_types] }
        let(:hash)           { { event_types: [] } }
        let(:event)          { described_class.from_hash(hash) }

        it { expect(event).to be_a described_class }

        it { expect(event.event_type).to be == expected_types.last }

        it { expect(event.event_types).to be == expected_types }

        it { expect(event.data).to be == {} }

        wrap_context 'when the event has data' do
          let(:hash) { super().merge(data: event_data) }

          it { expect(event.data).to be == event_data }
        end
      end

      describe 'with a Hash with one non-matching event type' do
        let(:expected_types) { [Ephesus::Core::Event::TYPE, *event_types] }
        let(:hash)           { { event_types: ['spec.other_event'] } }
        let(:error_message) do
          "expected event types to be #{expected_types.inspect}, but were " \
          "#{hash[:event_types]}"
        end

        it 'should raise an error' do
          expect { described_class.from_hash(hash) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with one matching event type' do
        let(:expected_types) { [Ephesus::Core::Event::TYPE, *event_types] }
        let(:hash)           { { event_types: [event_types.last] } }
        let(:event)          { described_class.from_hash(hash) }

        it { expect(event).to be_a described_class }

        it { expect(event.event_type).to be == expected_types.last }

        it { expect(event.event_types).to be == expected_types }

        it { expect(event.data).to be == {} }

        wrap_context 'when the event has data' do
          let(:hash) { super().merge(data: event_data) }

          it { expect(event.data).to be == event_data }
        end
      end

      describe 'with a Hash with many non-matching event types' do
        let(:other_types) do
          %w[
            spec.events.first_event
            spec.events.second_event
            spec.events.third_event
          ]
        end
        let(:expected_types) { [Ephesus::Core::Event::TYPE, *event_types] }
        let(:hash)           { { event_types: other_types } }
        let(:error_message) do
          "expected event types to be #{expected_types.inspect}, but were " \
          "#{hash[:event_types]}"
        end

        it 'should raise an error' do
          expect { described_class.from_hash(hash) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with a partially-matching event type' do
        let(:other_types) do
          %w[
            spec.events.grandparent_event
            spec.events.mystery_event
            spec.events.custom_event
          ]
        end
        let(:expected_types) { [Ephesus::Core::Event::TYPE, *event_types] }
        let(:hash)           { { event_types: other_types } }
        let(:error_message) do
          "expected event types to be #{expected_types.inspect}, but were " \
          "#{hash[:event_types]}"
        end

        it 'should raise an error' do
          expect { described_class.from_hash(hash) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a Hash with many matching event types' do
        let(:expected_types) { [Ephesus::Core::Event::TYPE, *event_types] }
        let(:hash) do
          { event_types: [Ephesus::Core::Event::TYPE, *event_types] }
        end
        let(:event) { described_class.from_hash(hash) }

        it { expect(event).to be_a described_class }

        it { expect(event.event_type).to be == expected_types.last }

        it { expect(event.event_types).to be == expected_types }

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

  describe '#event_type' do
    include_examples 'should have reader',
      :event_type,
      Ephesus::Core::Event::TYPE

    wrap_context 'with a custom event subclass with defined event types' do
      it { expect(instance.event_type).to be == event_types.last }
    end
  end

  describe '#event_types' do
    include_examples 'should have reader',
      :event_types,
      [Ephesus::Core::Event::TYPE]

    wrap_context 'with a custom event subclass with defined event types' do
      let(:expected) { [Ephesus::Core::Event::TYPE, *event_types] }

      it { expect(instance.event_types).to be == expected }
    end
  end
end
