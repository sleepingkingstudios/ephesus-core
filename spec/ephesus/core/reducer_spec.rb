# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/core/event_dispatcher'
require 'ephesus/core/reducer'

RSpec.describe Ephesus::Core::Reducer do
  shared_context 'when included in an application' do
    include_context 'with a reducer instance'

    let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
    let(:initial_state) do
      {
        era:      :renaissance,
        firearms: false,
        genre:    'High Fantasy'
      }
    end
    let(:application) do
      Spec::Application.new(event_dispatcher: event_dispatcher)
    end

    example_class 'Spec::Application',
      base_class: Ephesus::Core::Application \
    do |klass|
      klass.send :include, instance

      hsh = initial_state
      klass.send(:define_method, :initial_state) { hsh }

      klass.send(:define_method, :increment_era) do |state, _event|
        state.put(:era, :enlightenment)
      end
    end
  end

  shared_context 'with a reducer instance' do
    example_constant 'Spec::ExampleReducer' do
      described_class.new
    end

    let(:instance) { Spec::ExampleReducer }
  end

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#listeners' do
    include_examples 'should have reader', :listeners

    it { expect(instance.listeners).to be_a Hamster::Vector }

    it { expect(instance.listeners).to be_empty }
  end

  describe '#update' do
    let(:event_type) { 'spec.events.custom_event' }
    let(:event)      { Ephesus::Core::Event.new(event_type) }

    it 'should define the method' do
      expect(instance)
        .to respond_to(:update)
        .with(1..2)
        .arguments.and_a_block
    end

    describe 'with an event type but no definition' do
      let(:error_message) { 'must provide a method name or block' }

      it 'should raise an error' do
        expect { instance.update 'spec.events.custom_event' }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an event type and a block' do
      include_context 'when included in an application'

      it 'should add the listener' do
        block = -> {}

        expect { instance.update(event_type, &block) }
          .to change(instance, :listeners)
          .to(satisfy { |vec| vec.last == [event_type, block] })
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when the event is dispatched' do
        let(:expected) do
          initial_state.merge(firearms: true)
        end

        it 'should yield the current state and the event to the block' do
          expect do |block|
            instance.update(event_type, &block)

            application.event_dispatcher.dispatch_event(event)
          end
            .to yield_with_args(initial_state, event)
        end

        # rubocop:disable RSpec/ExampleLength
        it 'should update the state' do
          instance.update(event_type) do |state, _event|
            state.put(:firearms, true)
          end

          expect { application.event_dispatcher.dispatch_event(event) }
            .to change(application, :state)
            .to be == expected
        end
        # rubocop:enable RSpec/ExampleLength

        # rubocop:disable RSpec/ExampleLength
        it 'should execute the block in the context of the application' do
          instance.update(event_type) do |state, event|
            increment_era(state, event)
          end

          allow(application).to receive(:increment_era)

          application.event_dispatcher.dispatch_event(event)

          expect(application)
            .to have_received(:increment_era)
            .with(initial_state, event)
        end
        # rubocop:enable RSpec/ExampleLength
      end
      # rubocop:enable RSpec/NestedGroups
    end

    describe 'with an event type and a method name' do
      include_context 'when included in an application'

      let(:method_name) { :increment_era }

      it 'should add the listener' do
        expect { instance.update(event_type, method_name) }
          .to change(instance, :listeners)
          .to(satisfy { |vec| vec.last == [event_type, method_name] })
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when the event is dispatched' do
        let(:expected) do
          initial_state.merge(era: :enlightenment)
        end

        # rubocop:disable RSpec/ExampleLength
        it 'should call the method with the current state and the event' do
          instance.update(event_type, method_name)

          allow(application).to receive(method_name)

          application.event_dispatcher.dispatch_event(event)

          expect(application)
            .to have_received(method_name)
            .with(initial_state, event)
        end
        # rubocop:enable RSpec/ExampleLength

        it 'should update the state' do
          instance.update(event_type, method_name)

          expect { application.event_dispatcher.dispatch_event(event) }
            .to change(application, :state)
            .to be == expected
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end
end
