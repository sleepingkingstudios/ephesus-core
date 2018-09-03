# frozen_string_literal: true

require 'ephesus/core/actions/stop_current_controller'
require 'ephesus/core/event_dispatcher'

RSpec.describe Ephesus::Core::Actions::StopCurrentController do
  subject(:instance) do
    described_class.new(context, event_dispatcher: event_dispatcher)
  end

  let(:context)          { Object.new }
  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }

  describe '#call' do
    let(:event_type) do
      Ephesus::Core::Events::ControllerEvents::STOP_CURRENT_CONTROLLER
    end
    let(:dispatched_events) { [] }

    before(:example) do
      event_dispatcher.add_event_listener(Ephesus::Core::Event::TYPE) do |event|
        dispatched_events << event
      end
    end

    it { expect { instance.call }.to change(dispatched_events, :count).by(1) }

    it 'should dispatch a STOP_CURRENT_CONTROLLER event' do
      instance.call

      expect(dispatched_events.last.event_type)
        .to be == event_type
    end
  end
end
