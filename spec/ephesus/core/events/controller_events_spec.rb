# frozen_string_literal: true

require 'ephesus/core/events/controller_events'

RSpec.describe Ephesus::Core::Events::ControllerEvents do
  describe '::StartController' do
    let(:event_type) do
      'ephesus.core.events.controller_events.start_controller'
    end
    let(:event_class) { described_class::StartController }
    let(:event)       { event_class.new }

    include_examples 'should have constant',
      :START_CONTROLLER,
      -> { event_type }

    include_examples 'should have constant',
      :StartController,
      -> { an_instance_of Class }

    it { expect(event_class).to be < Ephesus::Core::Event }

    it { expect(event_class::TYPE).to be == event_type }

    it { expect(event.event_type).to be == event_type }

    it { expect(event).to have_property(:controller_type) }

    it { expect(event).to have_property(:controller_params) }
  end

  describe '::StopController' do
    let(:event_type) do
      'ephesus.core.events.controller_events.stop_controller'
    end
    let(:event_class) { described_class::StopController }
    let(:event)       { event_class.new }

    include_examples 'should have constant',
      :STOP_CONTROLLER,
      -> { event_type }

    include_examples 'should have constant',
      :StopController,
      -> { an_instance_of Class }

    it { expect(event_class).to be < Ephesus::Core::Event }

    it { expect(event_class::TYPE).to be == event_type }

    it { expect(event.event_type).to be == event_type }

    it { expect(event).to have_property(:identifier) }
  end

  describe '::StopCurrentController' do
    let(:event_type) do
      'ephesus.core.events.controller_events.stop_current_controller'
    end
    let(:event_class) { described_class::StopCurrentController }
    let(:event)       { event_class.new }

    include_examples 'should have constant',
      :STOP_CURRENT_CONTROLLER,
      -> { event_type }

    include_examples 'should have constant',
      :StopCurrentController,
      -> { an_instance_of Class }

    it { expect(event_class).to be < Ephesus::Core::Event }

    it { expect(event_class::TYPE).to be == event_type }

    it { expect(event.event_type).to be == event_type }
  end
end
