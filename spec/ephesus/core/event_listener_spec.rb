# frozen_string_literal: true

require 'ephesus/core/event_listener'

RSpec.describe Ephesus::Core::EventListener do
  subject(:instance) { described_class.new(event_type, &listener) }

  let(:event_type) { 'spec.events.example_event' }
  let(:listener)   { -> {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).to be_constructible.with(1).argument.and_a_block
    end
  end

  describe '#event_type' do
    include_examples 'should have reader', :event_type, -> { be == event_type }
  end

  describe '#update' do
    shared_examples 'should call the listener' do
      context 'when the listener does not take any arguments' do
        let(:listener) { -> {} }

        it 'should call the listener with no arguments' do
          instance.update(event)

          expect(listener).to have_received(:call).with(no_args)
        end
      end

      context 'when the listener takes at least one argument' do
        let(:listener) { ->(_event) {} }

        it 'should call the listener with the event' do
          instance.update(event)

          expect(listener).to have_received(:call).with(event)
        end
      end
    end

    before(:example) { allow(listener).to receive(:call) }

    let(:error_message) do
      'expected event to be a Ephesus::Core::Event'
    end

    it { expect(instance).to respond_to(:update).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { instance.update(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { instance.update(Object.new) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Event with a non-matching event type' do
      let(:event) { Ephesus::Core::Event.new('spec.events.other_event') }

      it 'should not call the listener' do
        instance.update(event)

        expect(listener).not_to have_received(:call)
      end
    end

    describe 'with an Event with a matching event type' do
      let(:event) { Ephesus::Core::Event.new(event_type) }

      include_examples 'should call the listener'
    end

    describe 'with an Event with a matching event type and parent types' do
      let(:event_types) do
        [
          'spec.events.grandparent_event',
          'spec.events.parent_event',
          event_type
        ]
      end
      let(:event) { Ephesus::Core::Event.new(*event_types) }

      include_examples 'should call the listener'
    end

    describe 'with an Event with a matching event type and child types' do
      let(:event_types) do
        [
          event_type,
          'spec.events.child_event',
          'spec.events.grandchild_event'
        ]
      end
      let(:event) { Ephesus::Core::Event.new(*event_types) }

      include_examples 'should call the listener'
    end
  end
end
