# frozen_string_literal: true

require 'bronze/entities/entity'

require 'ephesus/core/application'
require 'ephesus/core/controller'
require 'ephesus/core/events/controller_events'

require 'support/examples/event_handlers_examples'

RSpec.describe Ephesus::Core::Application do
  include Spec::Support::Examples::EventHandlersExamples

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

  wrap_context 'with an application subclass' do
    include_examples 'should implement the EventHandlers methods' do
      let(:instance_class) { described_class }
      let(:instance_args) do
        [{ event_dispatcher: event_dispatcher, repository: repository }]
      end
    end
  end

  describe 'when a START_CONTROLLER event is dispatched' do
    let(:keywords) { {} }
    let(:event) do
      Ephesus::Core::Events::ControllerEvents::StartController
        .new(controller_type: 'Spec::ExampleController', **keywords)
    end

    # rubocop:disable RSpec/SubjectStub
    before(:example) { allow(instance).to receive(:start_controller) }
    # rubocop:enable RSpec/SubjectStub

    it 'should start the controller' do
      event_dispatcher.dispatch_event(event)

      expect(instance)
        .to have_received(:start_controller)
        .with('Spec::ExampleController', {})
    end

    describe 'with controller params' do
      let(:params) do
        {
          pitch: '30 degrees',
          yaw:   '5 degrees',
          roll:  '15 degrees'
        }
      end
      let(:keywords) { super().merge controller_params: params }

      it 'should start the controller' do
        event_dispatcher.dispatch_event(event)

        expect(instance)
          .to have_received(:start_controller)
          .with('Spec::ExampleController', params)
      end
    end
  end

  describe 'when a STOP_ALL_CONTROLLERS event is dispatched' do
    let(:event) do
      Ephesus::Core::Events::ControllerEvents::StopAllControllers.new
    end

    # rubocop:disable RSpec/SubjectStub
    before(:example) { allow(instance).to receive(:stop_controller) }
    # rubocop:enable RSpec/SubjectStub

    wrap_context 'when the application has one controller' do
      it 'should stop the current controller' do
        event_dispatcher.dispatch_event(event)

        expect(instance)
          .to have_received(:stop_controller)
          .with(first_controller.identifier)
      end
    end

    wrap_context 'when the application has several controllers' do
      # rubocop:disable RSpec/ExampleLength
      it 'should stop each controller' do
        event_dispatcher.dispatch_event(event)

        [third_controller, second_controller, first_controller]
          .each do |controller|
            expect(instance)
              .to have_received(:stop_controller)
              .with(controller.identifier)
              .ordered
          end
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe 'when a STOP_CONTROLLER event is dispatched' do
    # rubocop:disable RSpec/SubjectStub
    before(:example) { allow(instance).to receive(:stop_controller) }
    # rubocop:enable RSpec/SubjectStub

    wrap_context 'when the application has one controller' do
      describe 'with the identifier of the current controller' do
        let(:event) do
          Ephesus::Core::Events::ControllerEvents::StopController
            .new(identifier: first_controller.identifier)
        end

        it 'should stop the current controller' do
          event_dispatcher.dispatch_event(event)

          expect(instance)
            .to have_received(:stop_controller)
            .with(first_controller.identifier)
        end
      end
    end

    wrap_context 'when the application has several controllers' do
      describe 'with the identifier of the current controller' do
        let(:event) do
          Ephesus::Core::Events::ControllerEvents::StopController
            .new(identifier: third_controller.identifier)
        end

        it 'should stop the current controller' do
          event_dispatcher.dispatch_event(event)

          expect(instance)
            .to have_received(:stop_controller)
            .with(third_controller.identifier)
        end
      end

      describe 'with the identifier of the specified controller' do
        let(:event) do
          Ephesus::Core::Events::ControllerEvents::StopController
            .new(identifier: second_controller.identifier)
        end

        it 'should stop the current controller' do
          event_dispatcher.dispatch_event(event)

          expect(instance)
            .to have_received(:stop_controller)
            .with(second_controller.identifier)
        end
      end
    end
  end

  describe 'when a STOP_CURRENT_CONTROLLER event is dispatched' do
    let(:event) do
      Ephesus::Core::Events::ControllerEvents::StopCurrentController.new
    end

    # rubocop:disable RSpec/SubjectStub
    before(:example) { allow(instance).to receive(:stop_controller) }
    # rubocop:enable RSpec/SubjectStub

    wrap_context 'when the application has one controller' do
      it 'should stop the current controller' do
        event_dispatcher.dispatch_event(event)

        expect(instance)
          .to have_received(:stop_controller)
          .with(first_controller.identifier)
      end
    end

    wrap_context 'when the application has several controllers' do
      it 'should stop the current controller' do
        event_dispatcher.dispatch_event(event)

        expect(instance)
          .to have_received(:stop_controller)
          .with(third_controller.identifier)
      end
    end
  end
end
