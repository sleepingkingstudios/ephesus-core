# frozen_string_literal: true

require 'ephesus/core/controllers/controller_builder'

RSpec.describe Ephesus::Core::Controllers::ControllerBuilder do
  shared_context 'when the builder has a repository' do
    let(:repository) { Spec::ExampleRepository.new }

    example_class 'Spec::ExampleRepository' do |klass|
      klass.send(:include, Bronze::Collections::Repository)
    end
  end

  subject(:instance) do
    described_class.new(
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { nil }

  example_class 'Spec::ExampleController', base_class: Ephesus::Core::Controller

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:event_dispatcher, :repository)
    end
  end

  describe '#build' do
    let(:error_message) do
      'expected controller to be a controller class or qualified name'
    end

    it 'should define the method' do
      expect(instance).to respond_to(:build).with(1).argument
    end

    describe 'with nil' do
      let(:error_message) { super() + ', but was nil' }

      it 'should raise an error' do
        expect { instance.build(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:object)        { Object.new }
      let(:error_message) { super() + ", but was #{object.inspect}" }

      it 'should raise an error' do
        expect { instance.build(object) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a Class' do
      let(:error_message) { super() + ', but was Object' }

      it 'should raise an error' do
        expect { instance.build(Object) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a Controller class' do
      let(:controller_class) { Spec::ExampleController }

      it 'should return a controller instance' do
        controller = instance.build(controller_class)

        expect(controller).to be_a controller_class
      end

      it 'should set the event dispatcher' do
        controller = instance.build(controller_class)

        expect(controller.event_dispatcher).to be event_dispatcher
      end

      it 'should set the repository' do
        controller = instance.build(controller_class)

        expect(controller.repository).to be nil
      end

      wrap_context 'when the builder has a repository' do
        it 'should set the repository' do
          controller = instance.build(controller_class)

          expect(controller.repository).to be repository
        end
      end
    end

    describe 'with a controller name that is not a Class name' do
      let(:controller_name) { 'NotAClassName' }
      let(:error_message)   { "uninitialized constant #{controller_name}" }

      it 'should raise an error' do
        expect { instance.build(controller_name) }
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
        expect { instance.build(controller_name) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with the name of a Controller class' do
      let(:controller_class) { Spec::ExampleController }
      let(:controller_name)  { controller_class.name }

      it 'should return a controller instance' do
        controller = instance.build(controller_name)

        expect(controller).to be_a controller_class
      end

      it 'should set the event dispatcher' do
        controller = instance.build(controller_name)

        expect(controller.event_dispatcher).to be event_dispatcher
      end

      it 'should set the repository' do
        controller = instance.build(controller_class)

        expect(controller.repository).to be nil
      end

      wrap_context 'when the builder has a repository' do
        it 'should set the repository' do
          controller = instance.build(controller_class)

          expect(controller.repository).to be repository
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

    wrap_context 'when the builder has a repository' do
      it { expect(instance.repository).to be repository }
    end
  end
end
