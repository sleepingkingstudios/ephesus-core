# frozen_string_literal: true

require 'ephesus/core/event_dispatcher'

RSpec.describe Ephesus::Core::EventDispatcher do
  shared_context 'when the dispatcher has an event listener' do
    let(:listener_block) { ->(_) {} }
    let!(:listener) do
      instance.add_event_listener(event_type, &listener_block)
    end

    before(:example) do
      allow(listener_block).to receive(:call)
    end
  end

  shared_context 'when the dispatcher has many event listeners' do
    let(:listeners)         { Hash.new { |hsh, key| hsh[key] = [] } }
    let!(:called_listeners) { [] }

    before(:example) do
      listeners['spec.events.number_event'] <<
        instance.add_event_listener('spec.events.number_event') do
          called_listeners << 'number'
        end

      listeners['spec.events.one_event'] <<
        instance.add_event_listener('spec.events.one_event') do
          called_listeners << 'one-the-first'
        end

      listeners['spec.events.one_event'] <<
        instance.add_event_listener('spec.events.one_event') do
          called_listeners << 'one-the-second'
        end

      listeners['spec.events.two_event'] <<
        instance.add_event_listener('spec.events.two_event') do
          # :nocov:
          called_listeners << 'two'
          # :nocov:
        end
    end
  end

  subject(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#add_event_listener' do
    let(:event_type) { 'spec.events.example_event' }
    let(:block)      { ->(_) {} }
    let(:event)      { Ephesus::Core::Event.new(event_type) }
    let(:listener)   { instance.add_event_listener(event_type, &block) }

    it 'should define the method' do
      expect(instance)
        .to respond_to(:add_event_listener)
        .with(1).argument
        .and_a_block
    end

    it { expect(listener).to be_a Ephesus::Core::EventListener }

    it { expect(listener.event_type).to be == event_type }

    it 'should call the block on #update' do
      allow(block).to receive(:call)

      listener.update(event)

      expect(block).to have_received(:call).with(event)
    end
  end

  describe '#dispatch_event' do
    let(:event_type) { 'spec.events.example_event' }

    it { expect(instance).to respond_to(:dispatch_event).with(1).argument }

    describe 'with nil' do
      let(:error_message) do
        'expected event to be a Ephesus::Core::Event'
      end

      it 'should raise an error' do
        expect { instance.dispatch_event nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) do
        'expected event to be a Ephesus::Core::Event'
      end

      it 'should raise an error' do
        expect { instance.dispatch_event Object.new }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Event' do
      let(:event) { Ephesus::Core::Event.new('spec.other_event') }

      it { expect { instance.dispatch_event event }.not_to raise_error }
    end

    wrap_context 'when the dispatcher has an event listener' do
      describe 'with an Event with a non-matching event_type' do
        let(:event) { Ephesus::Core::Event.new('spec.other_event') }

        it 'should not update the listener' do
          instance.dispatch_event event

          expect(listener_block).not_to have_received(:call)
        end
      end

      describe 'with an Event with an exact match event_type' do
        let(:event) { Ephesus::Core::Event.new(event_type) }

        it 'should update the listener' do
          instance.dispatch_event event

          expect(listener_block).to have_received(:call).with(event)
        end
      end

      describe 'with an Event with a partial match event_type' do
        let(:event_types) do
          [
            'spec.events.parent_event',
            event_type,
            'spec.events.child_event'
          ]
        end
        let(:event) { Ephesus::Core::Event.new(*event_types) }

        it 'should update the listener' do
          instance.dispatch_event event

          expect(listener_block).to have_received(:call).with(event)
        end
      end
    end

    wrap_context 'when the dispatcher has many event listeners' do
      describe 'with an Event with a non-matching event_type' do
        let(:event) { Ephesus::Core::Event.new('spec.other_event') }

        it 'should not update any listeners' do
          instance.dispatch_event event

          expect(called_listeners).to be == []
        end
      end

      describe 'with an Event matching one listener' do
        let(:event) { Ephesus::Core::Event.new('spec.events.number_event') }

        it 'should update the listener' do
          instance.dispatch_event event

          expect(called_listeners).to be == %w[number]
        end
      end

      describe 'with an Event matching many listeners' do
        let(:event_types) do
          [
            'spec.events.number_event',
            'spec.events.one_event'
          ]
        end
        let(:event) { Ephesus::Core::Event.new(*event_types) }

        it 'should update the matching listeners' do
          instance.dispatch_event event

          expect(called_listeners)
            .to contain_exactly('number', 'one-the-first', 'one-the-second')
        end
      end
    end
  end

  describe '#remove_all_listeners' do
    it 'should define the method' do
      expect(instance).to respond_to(:remove_all_listeners).with(0).arguments
    end

    wrap_context 'when the dispatcher has an event listener' do
      let(:event_type) { 'spec.events.example_event' }
      let(:event)      { Ephesus::Core::Event.new(event_type) }

      it 'should remove the listener' do
        instance.remove_all_listeners

        instance.dispatch_event(event)

        expect(listener_block).not_to have_received(:call)
      end
    end

    wrap_context 'when the dispatcher has many event listeners' do
      let(:event_type) { Ephesus::Core::Event::TYPE }
      let(:event)      { Ephesus::Core::Event.new(event_type) }

      it 'should remove all listeners' do
        instance.remove_all_listeners

        instance.dispatch_event(event)

        expect(called_listeners).to be_empty
      end
    end
  end

  describe '#remove_event_listener' do
    it 'should define the method' do
      expect(instance).to respond_to(:remove_event_listener).with(1).argument
    end

    describe 'with nil' do
      let(:error_message) do
        'expected listener to be a Ephesus::Core::EventListener'
      end

      it 'should raise an error' do
        expect { instance.remove_event_listener nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) do
        'expected listener to be a Ephesus::Core::EventListener'
      end

      it 'should raise an error' do
        expect { instance.remove_event_listener Object.new }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an EventListener' do
      let(:listener) { Ephesus::Core::EventListener.new('spec.some_event') {} }

      it 'should not raise an error' do
        expect { instance.remove_event_listener(listener) }.not_to raise_error
      end
    end

    wrap_context 'when the dispatcher has an event listener' do
      let(:event_type) { 'spec.events.example_event' }
      let(:event)      { Ephesus::Core::Event.new(event_type) }

      it 'should remove the listener' do
        instance.remove_event_listener(listener)

        instance.dispatch_event(event)

        expect(listener_block).not_to have_received(:call)
      end
    end

    wrap_context 'when the dispatcher has many event listeners' do
      let(:event_types) do
        [
          'spec.events.number_event',
          'spec.events.one_event'
        ]
      end
      let(:event)    { Ephesus::Core::Event.new(*event_types) }
      let(:listener) { listeners['spec.events.one_event'].first }

      it 'should remove the listener' do
        instance.remove_event_listener(listener)

        instance.dispatch_event(event)

        expect(called_listeners).to be == ['number', 'one-the-second']
      end
    end
  end
end
