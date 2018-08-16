# frozen_string_literal: true

require 'ephesus/core/events/event_registry'

RSpec.describe Ephesus::Core::Events::EventRegistry do
  let(:described_class) { Spec::EventRegistry }

  example_class 'Spec::EventRegistry' do |klass|
    # rubocop:disable RSpec/DescribedClass
    klass.send(:include, Ephesus::Core::Events::EventRegistry)
    # rubocop:enable RSpec/DescribedClass
  end

  describe '::event' do
    shared_context 'when the event is defined' do
      let(:event_class) { described_class.const_get(const_name) }
      let(:event_data)  { {} }
      let(:event)       { event_class.new(event_data) }

      before(:example) do
        args = [parent_class, *event_keys].compact

        described_class.event(event_name, *args)
      end
    end

    shared_examples 'should define the event subclass' do
      wrap_context 'when the event is defined' do
        it { expect(described_class).to have_constant(const_name) }

        it { expect(event_class).to be_a Class }

        it { expect(event_class).to be < Ephesus::Core::Event }

        it { expect(event_class).to be < parent_class if parent_class }

        it 'should define the ::TYPE constant' do
          expect(event_class).to have_constant(:TYPE).with_value(event_type)
        end

        it { expect(event_class.keys).to be == expected_keys }

        it { expect(event.event_type).to be == event_type }

        it { expect(event.event_types).to be == expected_types }

        it { expect(event.data).to be == expected_data }
      end
    end

    let(:event_name)    { :custom_event }
    let(:event_keys)    { [] }
    let(:const_name)    { 'CustomEvent' }
    let(:event_type)    { 'spec.event_registry.custom_event' }
    let(:parent_class)  { nil }
    let(:expected_keys) { Set.new(event_keys.sort) }
    let(:expected_data) { {} }
    let(:expected_types) do
      [
        parent_class&.event_types || Ephesus::Core::Event::TYPE,
        event_type
      ]
        .flatten
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:event)
        .with(1).argument
        .and_unlimited_arguments
    end

    it 'should return the constant name' do
      expect(described_class.event event_name).to be const_name.intern
    end

    include_examples 'should define the event subclass'

    describe 'with event keys' do
      let(:event_keys) { %i[fire wood water] }
      let(:expected_data) do
        super().merge(
          fire:  nil,
          water: nil,
          wood:  nil
        )
      end

      include_examples 'should define the event subclass'
    end

    describe 'with a parent class' do
      let(:parent_name)   { :parent_event }
      let(:parent_keys)   { %i[air earth metal] }
      let(:parent_class)  { described_class::ParentEvent }
      let(:expected_keys) { Set.new(parent_keys) }
      let(:expected_data) do
        super().merge(
          air:   nil,
          earth: nil,
          metal: nil
        )
      end

      before(:example) do
        described_class.event(parent_name, *parent_keys)
      end

      include_examples 'should define the event subclass'

      describe 'with event keys' do # rubocop:disable RSpec/NestedGroups
        let(:event_keys)    { %i[fire wood water] }
        let(:expected_keys) { Set.new((parent_keys + event_keys).sort) }
        let(:expected_data) do
          super().merge(
            air:   nil,
            fire:  nil,
            earth: nil,
            metal: nil,
            water: nil,
            wood:  nil
          )
        end

        include_examples 'should define the event subclass'
      end
    end
  end
end
