# frozen_string_literal: true

require 'ephesus/core/event'

RSpec.describe Ephesus::Core::Event do
  shared_context 'with an event type' do
    let(:event_type)  { 'spec.events.example_event' }
    let(:event_types) { [event_type] }
  end

  shared_context 'with a hierarchy of event types' do
    let(:event_types) do
      %w[
        spec.events.grandparent_event
        spec.events.parent_event
        spec.events.custom_event
      ]
    end
    let(:event_type) { event_types }
  end

  shared_context 'with an event subclass' do
    let(:subclass_type) { defined?(super) ? super() : 'example_subclass' }
    let(:subclass_keys) { defined?(super) ? super() : [] }
    let(:described_class) do
      # rubocop:disable RSpec/DescribedClass
      Ephesus::Core::Event.subclass(subclass_type, *subclass_keys)
      # rubocop:enable RSpec/DescribedClass
    end
    let(:instance) { described_class.new(**event_data) }
  end

  shared_context 'when the event has data' do
    let(:event_data) do
      {
        english:  'shortsword',
        german:   'einhänder',
        japanese: 'shoto'
      }
    end
  end

  subject(:instance) { described_class.new(*event_types, **event_data) }

  let(:event_types) { [] }
  let(:event_data)  { {} }

  describe '::TYPE' do
    include_examples 'should have immutable constant',
      :TYPE,
      'ephesus.core.event'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
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

      it { expect(event.event_type).to be == described_class::TYPE }

      it { expect(event.event_types).to be == [described_class::TYPE] }

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

      it { expect(event.event_type).to be == described_class::TYPE }

      it { expect(event.event_types).to be == [described_class::TYPE] }

      it { expect(event.data).to be == {} }

      wrap_context 'when the event has data' do
        let(:hash) { super().merge(data: event_data) }

        it { expect(event.data).to be == event_data }
      end
    end

    describe 'with a Hash with one event type' do
      let(:expected_types) { [described_class::TYPE, *hash[:event_types]] }
      let(:hash)           { { event_types: ['spec.example_event'] } }
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

    describe 'with a Hash with many event types' do
      let(:expected_types) { [described_class::TYPE, *hash[:event_types]] }
      let(:event_types) do
        %w[
          spec.events.grandparent_event
          spec.events.parent_event
          spec.events.custom_event
        ]
      end
      let(:hash)  { { event_types: event_types } }
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

  describe '::keys' do
    include_examples 'should have class reader', :keys, -> { be == Set.new }

    wrap_context 'with an event subclass' do
      it { expect(described_class.keys).to be == Set.new }

      context 'when the class has data keys' do
        let(:expected_keys) { Set.new(subclass_keys.sort) }
        let(:subclass_keys) { %i[iroquois polynesian aztec] }

        it { expect(described_class.keys).to be == expected_keys }
      end
    end
  end

  describe '::subclass' do
    shared_examples 'should delegate to EventBuilder#build' do
      # rubocop:disable RSpec/ExampleLength
      it 'should delegate to EventBuilder#build' do
        allow(Ephesus::Core::Events::EventBuilder)
          .to receive(:new)
          .with(described_class)
          .and_return(event_builder)

        allow(event_builder)
          .to receive(:build)
          .with(event_type, event_keys)
          .and_return(event_subclass)

        expect(described_class.subclass(event_type, *event_keys))
          .to be event_subclass
      end
      # rubocop:enable RSpec/ExampleLength
    end

    let(:event_type)     { 'example_subclass' }
    let(:event_keys)     { %i[iroquois polynesian aztec] }
    let(:event_subclass) { Class.new(described_class) }
    let(:event_builder) do
      Ephesus::Core::Events::EventBuilder.new(described_class)
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:subclass)
        .with(1).argument
        .and_unlimited_arguments
    end

    include_examples 'should delegate to EventBuilder#build'

    wrap_context 'with an event subclass' do
      include_examples 'should delegate to EventBuilder#build'
    end
  end

  describe '#==' do
    it { expect(instance).to respond_to(:==).with(1).argument }

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(instance == nil).to be false }
      # rubocop:enable Style/NilComparison
    end

    describe 'with an Object' do
      it { expect(instance == Object.new).to be false }
    end

    describe 'with an Event with non-matching event_type' do
      let(:event) { described_class.new('spec.other_event_type') }

      it { expect(instance == event).to be false }
    end

    describe 'with an Event with matching event_type' do
      let(:event) { described_class.new }

      it { expect(instance == event).to be true }

      wrap_context 'when the event has data' do
        it { expect(instance == event).to be false }
      end
    end

    describe 'with an Event with matching event_type and data' do
      let(:event) { described_class.new(instance.data) }

      it { expect(instance == event).to be true }

      wrap_context 'when the event has data' do
        it { expect(instance == event).to be true }
      end
    end

    describe 'with a non-matching event type' do
      it { expect(instance == 'spec.other_event_type').to be false }
    end

    describe 'with Event::TYPE' do
      it { expect(instance == described_class::TYPE).to be true }
    end

    wrap_context 'with an event type' do
      describe 'with an Event with non-matching event_type' do
        let(:event) { described_class.new('spec.other_event_type') }

        it { expect(instance == event).to be false }
      end

      describe 'with an Event with matching event_type' do
        let(:event) { described_class.new(instance.event_type) }

        it { expect(instance == event).to be true }

        wrap_context 'when the event has data' do
          it { expect(instance == event).to be false }
        end
      end

      describe 'with an Event with matching event_type and data' do
        let(:event) { described_class.new(instance.event_type, instance.data) }

        it { expect(instance == event).to be true }

        wrap_context 'when the event has data' do
          it { expect(instance == event).to be true }
        end
      end

      describe 'with a non-matching event type' do
        it { expect(instance == 'spec.other_event_type').to be false }
      end

      describe 'with Event::TYPE' do
        it { expect(instance == described_class::TYPE).to be true }
      end

      describe "with the event's event type" do
        it { expect(instance == event_type).to be true }
      end
    end

    wrap_context 'with a hierarchy of event types' do
      describe 'with an Event with non-matching event_type' do
        let(:event) { described_class.new('spec.other_event_type') }

        it { expect(instance == event).to be false }
      end

      describe 'with an Event with matching event_type' do
        let(:event) { described_class.new(*event_types) }

        it { expect(instance == event).to be true }

        wrap_context 'when the event has data' do
          it { expect(instance == event).to be false }
        end
      end

      describe 'with an Event with matching event_type and data' do
        let(:event) { described_class.new(*event_types, instance.data) }

        it { expect(instance == event).to be true }

        wrap_context 'when the event has data' do
          it { expect(instance == event).to be true }
        end
      end

      describe 'with a non-matching event type' do
        it { expect(instance == 'spec.other_event_type').to be false }
      end

      describe 'with Event::TYPE' do
        it { expect(instance == described_class::TYPE).to be true }
      end

      describe "with the event's event type" do
        it { expect(instance == event_types.last).to be true }
      end

      describe 'with an ancestor event type' do
        it { expect(instance == event_types.first).to be true }
      end
    end
  end

  describe '#<' do
    it { expect(instance).to respond_to(:<).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { instance < nil }
          .to raise_error ArgumentError, 'comparison of Event with nil failed'
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { instance < Object.new }
          .to raise_error ArgumentError,
            'comparison of Event with Object failed'
      end
    end

    describe 'with a non-matching event type' do
      it { expect(instance < 'spec.other_event_type').to be false }
    end

    describe 'with Event::TYPE' do
      it { expect(instance < described_class::TYPE).to be false }
    end

    wrap_context 'with an event type' do
      describe 'with a non-matching event type' do
        it { expect(instance < 'spec.other_event_type').to be false }
      end

      describe 'with Event::TYPE' do
        it { expect(instance < described_class::TYPE).to be true }
      end

      describe 'with a matching event type' do
        it { expect(instance < event_type).to be false }
      end
    end

    wrap_context 'with a hierarchy of event types' do
      describe 'with a non-matching event type' do
        it { expect(instance < 'spec.other_event_type').to be false }
      end

      describe 'with Event::TYPE' do
        it { expect(instance < described_class::TYPE).to be true }
      end

      describe "with the event's event type" do
        it { expect(instance < event_types.last).to be false }
      end

      describe 'with an ancestor event type' do
        it { expect(instance < event_types.first).to be true }
      end
    end
  end

  describe '#<=' do
    it { expect(instance).to respond_to(:<=).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { instance <= nil }
          .to raise_error ArgumentError, 'comparison of Event with nil failed'
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { instance <= Object.new }
          .to raise_error ArgumentError,
            'comparison of Event with Object failed'
      end
    end

    describe 'with a non-matching event type' do
      it { expect(instance <= 'spec.other_event_type').to be false }
    end

    describe 'with Event::TYPE' do
      it { expect(instance <= described_class::TYPE).to be true }
    end

    wrap_context 'with an event type' do
      describe 'with a non-matching event type' do
        it { expect(instance <= 'spec.other_event_type').to be false }
      end

      describe 'with Event::TYPE' do
        it { expect(instance <= described_class::TYPE).to be true }
      end

      describe 'with a matching event type' do
        it { expect(instance <= event_type).to be true }
      end
    end

    wrap_context 'with a hierarchy of event types' do
      describe 'with a non-matching event type' do
        it { expect(instance <= 'spec.other_event_type').to be false }
      end

      describe 'with Event::TYPE' do
        it { expect(instance <= described_class::TYPE).to be true }
      end

      describe "with the event's event type" do
        it { expect(instance <= event_types.last).to be true }
      end

      describe 'with an ancestor event type' do
        it { expect(instance <= event_types.first).to be true }
      end
    end
  end

  describe '#data' do
    include_examples 'should have reader', :data, -> { event_data }

    wrap_context 'when the event has data' do
      it { expect(instance.data).to be == event_data }
    end
  end

  describe '#event_type' do
    include_examples 'should have reader', :event_type, described_class::TYPE

    wrap_context 'with an event type' do
      it { expect(instance.event_type).to be == event_type }
    end

    wrap_context 'with a hierarchy of event types' do
      it { expect(instance.event_type).to be == event_types.last }
    end
  end

  describe '#event_types' do
    include_examples 'should have reader',
      :event_types,
      -> { [described_class::TYPE] }

    wrap_context 'with an event type' do
      it 'should return the event types' do
        expect(instance.event_types)
          .to be == [described_class::TYPE, *event_types]
      end
    end

    wrap_context 'with a hierarchy of event types' do
      it 'should return the event types' do
        expect(instance.event_types)
          .to be == [described_class::TYPE, *event_types]
      end
    end
  end

  describe '#to_h' do
    let(:expected) do
      {
        event_types: instance.event_types,
        data:        instance.data
      }
    end

    it { expect(instance).to respond_to(:to_h).with(0).arguments }

    it { expect(instance.to_h).to be == expected }

    wrap_context 'when the event has data' do
      it { expect(instance.to_h).to be == expected }
    end

    wrap_context 'with an event type' do
      it { expect(instance.to_h).to be == expected }

      wrap_context 'when the event has data' do
        it { expect(instance.to_h).to be == expected }
      end
    end

    wrap_context 'with a hierarchy of event types' do
      it { expect(instance.to_h).to be == expected }

      wrap_context 'when the event has data' do
        it { expect(instance.to_h).to be == expected }
      end
    end

    wrap_context 'with an event subclass' do
      it { expect(instance.to_h).to be == expected }

      wrap_context 'when the event has data' do
        it { expect(instance.to_h).to be == expected }
      end
    end
  end
end
