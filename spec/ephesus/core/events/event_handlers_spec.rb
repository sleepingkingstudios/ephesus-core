# frozen_string_literal: true

require 'ephesus/core/event_dispatcher'
require 'ephesus/core/events/event_handlers'

require 'support/examples/event_handlers_examples'

RSpec.describe Ephesus::Core::Events::EventHandlers do
  include Spec::Support::Examples::EventHandlersExamples

  subject(:instance) { described_class.new(event_dispatcher: event_dispatcher) }

  let(:described_class)  { Spec::EventHandlers }
  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }

  example_class 'Spec::EventHandlers' do |klass|
    # rubocop:disable RSpec/DescribedClass
    klass.send(:include, Ephesus::Core::Events::EventHandlers)
    # rubocop:enable RSpec/DescribedClass
  end

  describe '::new' do
    # rubocop:disable RSpec/ExampleLength
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_unlimited_arguments
        .and_keywords(:event_dispatcher)
        .and_a_block
    end
    # rubocop:enable RSpec/ExampleLength
  end

  include_examples 'should implement the EventHandlers methods' do
    let(:instance_class) { described_class }
    let(:instance_args)  { [{ event_dispatcher: event_dispatcher }] }
  end
end
