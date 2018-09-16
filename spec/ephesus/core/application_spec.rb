# frozen_string_literal: true

require 'bronze/entities/entity'

require 'ephesus/core/application'
require 'ephesus/core/controller'
require 'ephesus/core/events/controller_events'

RSpec.describe Ephesus::Core::Application do
  shared_context 'when the application has one controller' do
    let!(:first_controller) do
      instance.start_controller(Spec::ExampleController)
    end
  end

  shared_context 'when the application has several controllers' do
    let!(:first_controller) do
      instance.start_controller(Spec::ExampleController)
    end
    let!(:second_controller) do
      instance.start_controller(Spec::ExampleController)
    end
    let!(:third_controller) do
      instance.start_controller(Spec::ExampleController)
    end
  end

  shared_context 'when the application has a repository' do
    let(:repository) { Spec::ExampleRepository.new }

    example_class 'Spec::ExampleRepository' do |klass|
      klass.send(:include, Bronze::Collections::Repository)
    end
  end

  shared_context 'when the initial state is defined' do
    include_context 'with an application subclass'

    let(:initial_state) do
      {
        era:      :renaissance,
        firearms: false,
        genre:    'High Fantasy'
      }
    end

    before(:example) do
      hsh = initial_state

      Spec::ExampleApplication.define_method(:initial_state) { hsh }
    end
  end

  shared_context 'with an application subclass' do
    let(:described_class) { Spec::ExampleApplication }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleApplication',
      base_class: Ephesus::Core::Application
    # rubocop:enable RSpec/DescribedClass
  end

  subject(:instance) do
    described_class.new(
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { nil }

  example_class 'Spec::ExampleController',
    base_class: Ephesus::Core::Controller \
  do |klass|
    klass.define_method(:build_context) do |**kwargs|
      Struct.new(:id, *kwargs.keys).new(0, *kwargs.values)
    end
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:event_dispatcher, :repository)
    end
  end

  describe '#add_event_listener' do
    let(:event_type) { 'spec.events.custom_event' }
    let(:event)      { Ephesus::Core::Event.new(event_type) }

    it 'should define the method' do
      expect(instance)
        .to respond_to(:add_event_listener)
        .with(1..2).arguments
        .and_a_block
    end

    describe 'with no definition' do
      let(:error_message) do
        'listener must be a method name or a block'
      end

      it 'should raise an error' do
        expect { instance.add_event_listener(event_type) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block with no arguments' do
      it 'should call the block with no arguments' do
        called = false
        block  = -> { called = true }

        instance.add_event_listener(event_type, &block)

        event_dispatcher.dispatch_event(event)

        expect(called).to be true
      end
    end

    describe 'with a block with one argument' do
      it 'should call the block with the event' do
        args  = []
        block = ->(event) { args << event }

        instance.add_event_listener(event_type, &block)

        event_dispatcher.dispatch_event(event)

        expect(args).to contain_exactly(event)
      end
    end

    describe 'with the name of an undefined method' do
      let(:method_name) { :custom_event_handler }
      let(:error_message) do
        "undefined method `#{method_name}' for class `#{described_class}'"
      end

      it 'should raise an error' do
        expect { instance.add_event_listener(event_type, method_name) }
          .to raise_error NameError, error_message
      end
    end

    describe 'with the name of a method with no arguments' do
      let(:method_name) { :custom_event_handler }

      it 'should call the method with no arguments' do
        called = false

        instance.define_singleton_method(method_name) { called = true }

        instance.add_event_listener(event_type, method_name)

        event_dispatcher.dispatch_event(event)

        expect(called).to be true
      end
    end

    describe 'with the name of a method with one argument' do
      let(:method_name) { :custom_event_handler }

      # rubocop:disable RSpec/ExampleLength
      it 'should call the method with the event' do
        arguments = []

        instance.define_singleton_method(method_name) do |*args|
          arguments = args
        end

        instance.add_event_listener(event_type, method_name)

        event_dispatcher.dispatch_event(event)

        expect(arguments).to be == [event]
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#current_controller' do
    include_examples 'should have reader', :current_controller, nil

    wrap_context 'when the application has one controller' do
      it { expect(instance.current_controller).to be first_controller }
    end

    wrap_context 'when the application has several controllers' do
      it { expect(instance.current_controller).to be third_controller }
    end
  end

  describe '#execute_action' do
    it 'should define the method' do
      expect(instance)
        .to respond_to(:execute_action)
        .with(1).argument
        .and_unlimited_arguments
    end

    it 'should raise an error' do
      expect { instance.execute_action(:defenestrate) }
        .to raise_error RuntimeError, 'application does not have a controller'
    end

    wrap_context 'when the application has one controller' do
      let(:action_name) { :rock_climb }

      describe 'with no arguments' do
        it 'should delegate to the current controller' do
          allow(instance.current_controller).to receive(:execute_action)

          instance.execute_action(action_name)

          expect(instance.current_controller)
            .to have_received(:execute_action)
            .with(action_name)
        end
      end

      describe 'with many arguments' do
        let(:arguments) { [:one, :two, { three: 3 }] }

        it 'should delegate to the current controller' do
          allow(instance.current_controller).to receive(:execute_action)

          instance.execute_action(action_name, *arguments)

          expect(instance.current_controller)
            .to have_received(:execute_action)
            .with(action_name, *arguments)
        end
      end
    end
  end

  describe '#event_dispatcher' do
    include_examples 'should have reader',
      :event_dispatcher,
      -> { event_dispatcher }
  end

  describe '#repository' do
    include_examples 'should have reader', :repository, nil

    wrap_context 'when the application has a repository' do
      it { expect(instance.repository).to be repository }
    end
  end

  describe '#start_controller' do
    shared_examples 'should create and start the controller' do
      it 'should start the controller' do
        controller = instance_double(controller_class, start: nil)

        allow(controller_class).to receive(:new).and_return(controller)

        start_controller

        expect(controller).to have_received(:start).with(keywords)
      end

      it 'should add the controller to the application controllers' do
        expect { start_controller }
          .to change { instance.send(:controllers).count }
          .by(1)
      end

      it 'should set the current controller' do
        expect { start_controller }
          .to change(instance, :current_controller)
          .to an_instance_of controller_class
      end

      it 'should return the current controller' do
        controller = start_controller

        expect(controller).to be instance.current_controller
      end

      it 'should set the controller context' do
        start_controller

        expect(instance.current_controller.context).to be_a Struct
      end

      it 'should set the controller event dispatcher' do
        start_controller

        expect(instance.current_controller.event_dispatcher)
          .to be event_dispatcher
      end

      it 'should set the controller repository' do
        start_controller

        expect(instance.current_controller.repository).to be nil
      end

      wrap_context 'when the application has a repository' do
        it 'should set the controller repository' do
          start_controller

          expect(instance.current_controller.repository).to be repository
        end
      end

      describe 'with keywords' do
        let(:keywords) do
          {
            pitch: '30 degrees',
            yaw:   '5 degrees',
            roll:  '15 degrees'
          }
        end

        it 'should set the controller context' do
          instance.start_controller(controller_class, keywords)

          expect(instance.current_controller.context).to be_a Struct
        end

        it 'should set the controller context values' do
          instance.start_controller(controller_class, keywords)

          keywords.each do |key, value|
            expect(instance.current_controller.context.send(key)).to be == value
          end
        end
      end
    end

    let(:keywords) { {} }
    let(:error_message) do
      'expected controller to be a controller class or qualified name'
    end

    it 'should define the method' do
      expect(instance)
        .to respond_to(:start_controller)
        .with(1).argument
        .and_any_keywords
    end

    describe 'with nil' do
      let(:error_message) { super() + ', but was nil' }

      it 'should raise an error' do
        expect { instance.start_controller(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:object)        { Object.new }
      let(:error_message) { super() + ", but was #{object.inspect}" }

      it 'should raise an error' do
        expect { instance.start_controller(object) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a Class' do
      let(:error_message) { super() + ', but was Object' }

      it 'should raise an error' do
        expect { instance.start_controller(Object) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a Controller class' do
      let(:controller_class) { Spec::ExampleController }

      def start_controller
        instance.start_controller(controller_class, **keywords)
      end

      include_context 'should create and start the controller'

      wrap_context 'when the application has one controller' do
        include_context 'should create and start the controller'
      end

      wrap_context 'when the application has several controllers' do
        include_context 'should create and start the controller'
      end
    end

    describe 'with a controller name that is not a Class name' do
      let(:controller_name) { 'NotAClassName' }
      let(:error_message)   { "uninitialized constant #{controller_name}" }

      it 'should raise an error' do
        expect { instance.start_controller(controller_name) }
          .to raise_error NameError, error_message
      end
    end

    describe 'with a controller name that is not a Controller class name' do
      let(:controller_name) { 'Object' }
      let(:error_message) do
        "expected #{controller_name} to be a subclass of " \
        'Ephesus::Core::Controller'
      end

      it 'should raise an error' do
        expect { instance.start_controller(controller_name) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with the name of a Controller class' do
      let(:controller_class) { Spec::ExampleController }
      let(:controller_name)  { controller_class.name }

      def start_controller
        instance.start_controller(controller_name, **keywords)
      end

      include_context 'should create and start the controller'

      wrap_context 'when the application has one controller' do
        include_context 'should create and start the controller'
      end

      wrap_context 'when the application has several controllers' do
        include_context 'should create and start the controller'
      end
    end
  end

  describe '#state' do
    include_examples 'should have reader', :state

    it { expect(instance.state).to be_a Hamster::Hash }

    it { expect(instance.state).to be_empty }

    wrap_context 'when the initial state is defined' do
      it { expect(instance.state).to be_a Hamster::Hash }

      it { expect(instance.state).to be == initial_state }
    end
  end

  describe '#stop_controller' do
    it { expect(instance).to respond_to(:stop_controller).with(1).argument }

    describe 'with nil' do
      let(:error_message) { 'invalid identifier nil' }

      it 'should raise an error' do
        expect { instance.stop_controller nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an object' do
      let(:object)        { Object.new }
      let(:error_message) { "invalid identifier #{object.inspect}" }

      it 'should raise an error' do
        expect { instance.stop_controller object }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an invalid identifier' do
      let(:identifier)    { '0b8d90e5-018d-420a-bfb7-5c96253e4a53' }
      let(:error_message) { "invalid identifier #{identifier.inspect}" }

      it 'should raise an error' do
        expect { instance.stop_controller identifier }
          .to raise_error ArgumentError, error_message
      end
    end

    wrap_context 'when the application has one controller' do
      describe 'with an invalid identifier' do
        let(:identifier)    { '0b8d90e5-018d-420a-bfb7-5c96253e4a53' }
        let(:error_message) { "invalid identifier #{identifier.inspect}" }

        it 'should raise an error' do
          expect { instance.stop_controller identifier }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a valid identifier' do
        let(:identifier) { first_controller.identifier }

        it 'should stop the controller' do
          allow(first_controller).to receive(:stop)

          instance.stop_controller(identifier)

          expect(first_controller).to have_received(:stop)
        end

        it 'should remove the controller from the application controllers' do
          expect { instance.stop_controller(identifier) }
            .to change { instance.send(:controllers).count }
            .by(-1)
        end

        it 'should clear the current controller' do
          expect { instance.stop_controller identifier }
            .to change(instance, :current_controller)
            .to be nil
        end
      end
    end

    wrap_context 'when the application has several controllers' do
      describe 'with an invalid identifier' do
        let(:identifier)    { '0b8d90e5-018d-420a-bfb7-5c96253e4a53' }
        let(:error_message) { "invalid identifier #{identifier.inspect}" }

        it 'should raise an error' do
          expect { instance.stop_controller identifier }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a valid identifier for the current controller' do
        let(:identifier) { third_controller.identifier }

        it 'should stop the controller' do
          allow(third_controller).to receive(:stop)

          instance.stop_controller(identifier)

          expect(third_controller).to have_received(:stop)
        end

        it 'should remove the controller from the application controllers' do
          expect { instance.stop_controller(identifier) }
            .to change { instance.send(:controllers).count }
            .by(-1)
        end

        it 'should set the current controller' do
          expect { instance.stop_controller identifier }
            .to change(instance, :current_controller)
            .to be second_controller
        end
      end

      describe 'with a valid identifier for an inner controller' do
        let(:identifier) { second_controller.identifier }

        it 'should stop the controller' do
          allow(second_controller).to receive(:stop)

          instance.stop_controller(identifier)

          expect(second_controller).to have_received(:stop)
        end

        it 'should remove the controller from the application controllers' do
          expect { instance.stop_controller(identifier) }
            .to change { instance.send(:controllers).count }
            .by(-1)
        end

        it 'should not change the current controller' do
          expect { instance.stop_controller identifier }
            .not_to change(instance, :current_controller)
        end
      end
    end
  end
end
