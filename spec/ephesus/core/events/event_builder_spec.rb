# frozen_string_literal: true

require 'ephesus/core/event'
require 'ephesus/core/events/event_builder'

RSpec.describe Ephesus::Core::Events::EventBuilder do
  shared_context 'when the parent class is a custom event class' do
    let(:parent_class) { Spec::ExampleEvent }

    example_class 'Spec::ExampleEvent', base_class: Ephesus::Core::Event
  end

  shared_context 'when the parent class is an event subclass' do
    let(:subclass_type) { 'spec.example_subclass' }
    let(:subclass_keys) { %i[bantu chinese indonesian] }
    let(:parent_class) do
      described_class.new.build(subclass_type, subclass_keys)
    end
  end

  subject(:instance) { described_class.new(parent_class) }

  let(:parent_class) { nil }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '#build' do
    shared_context 'when the event has data' do
      let(:event_data) do
        {
          english:  'shortsword',
          german:   'einhänder',
          japanese: 'shoto'
        }
      end
    end

    shared_examples 'should define a subclass of the parent class' do
      it { expect(subclass).to be_a Class }

      it { expect(subclass).to be < Ephesus::Core::Event }

      it 'should be a subclass of the parent class' do
        expect(subclass).to be < (parent_class || Ephesus::Core::Event)
      end
    end

    shared_examples 'should set the ::keys' do
      it { expect(subclass.keys).to be == Set.new(expected_keys.sort) }
    end

    shared_examples 'should set the #event_type' do
      it { expect(event.event_type).to be == event_type }
    end

    shared_examples 'should set the #data' do
      it { expect(event.data).to be == expected_data }
    end

    shared_examples 'should define the data property methods' do
      it 'should define the data reader methods', :aggregate_failures do
        expected_keys.each do |key|
          expect(event).to have_reader(key).with_value(event_data[key])
        end
      end

      it 'should define the data writer methods', :aggregate_failures do
        expected_keys.each do |key|
          expect(event).to have_writer(:"#{key}=")
        end
      end

      it 'should update the data', :aggregate_failures do
        expected_keys.each do |key|
          expect { event.send(:"#{key}=", 'noodle') }
            .to change { event.data[key] }
            .to be == 'noodle'
        end
      end
    end

    shared_examples 'should define an event subclass' do
      include_examples 'should define a subclass of the parent class'

      include_examples 'should set the ::keys'

      include_examples 'should set the #event_type'

      include_examples 'should set the #data'
    end

    let(:event_type)    { 'spec.events.event_subclass' }
    let(:event_keys)    { [] }
    let(:subclass)      { instance.build(event_type, event_keys) }
    let(:event_data)    { {} }
    let(:event)         { subclass.new(event_data) }
    let(:expected_keys) { event_keys }
    let(:expected_data) { generate_expected_data(expected_keys) }

    def generate_expected_data(expected_keys)
      default_data =
        expected_keys.each.with_object({}) { |key, hsh| hsh[key] = nil }

      default_data.merge(event_data)
    end

    it 'should define the method' do
      expect(instance)
        .to respond_to(:build)
        .with(2).arguments
    end

    include_examples 'should define an event subclass'

    wrap_context 'when the event has data' do
      include_examples 'should define an event subclass'
    end

    describe 'with event keys' do
      let(:event_keys) { %i[english french german] }

      include_examples 'should define an event subclass'

      include_examples 'should define the data property methods'

      wrap_context 'when the event has data' do
        include_examples 'should define an event subclass'

        include_examples 'should define the data property methods'
      end
    end

    wrap_context 'when the parent class is a custom event class' do
      include_examples 'should define an event subclass'

      wrap_context 'when the event has data' do
        include_examples 'should define an event subclass'
      end

      describe 'with event keys' do
        let(:event_keys) { %i[english french german] }

        include_examples 'should define an event subclass'

        include_examples 'should define the data property methods'

        wrap_context 'when the event has data' do
          include_examples 'should define an event subclass'

          include_examples 'should define the data property methods'
        end
      end
    end

    wrap_context 'when the parent class is an event subclass' do
      let(:expected_keys) { subclass_keys + event_keys }

      include_examples 'should define an event subclass'

      wrap_context 'when the event has data' do
        include_examples 'should define an event subclass'
      end

      describe 'with event keys' do
        let(:event_keys) { %i[english french german] }

        include_examples 'should define an event subclass'

        include_examples 'should define the data property methods'

        wrap_context 'when the event has data' do
          include_examples 'should define an event subclass'

          include_examples 'should define the data property methods'
        end
      end
    end
  end

  describe '#parent_class' do
    include_examples 'should have reader',
      :parent_class,
      -> { Ephesus::Core::Event }

    wrap_context 'when the parent class is a custom event class' do
      it { expect(instance.parent_class).to be parent_class }
    end

    wrap_context 'when the parent class is an event subclass' do
      it { expect(instance.parent_class).to be parent_class }
    end
  end
end
