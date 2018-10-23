# frozen_string_literal: true

require 'bronze/collections/repository'

require 'ephesus/core/application'
require 'ephesus/core/controller'
require 'ephesus/core/event_dispatcher'
require 'ephesus/core/session'

RSpec.describe Ephesus::Core::Session do
  shared_context 'with a chain of controllers' do
    include_context 'with a non-matching conditional controller'
    include_context 'with a matching conditional controller'
    include_context 'with a non-conditional controller'
  end

  shared_context 'with a non-matching conditional controller' do
    example_class 'Spec::NonMatchingConditionalController',
      base_class: Ephesus::Core::Controller

    before(:example) do
      conditional = ->(state) { state.get(:landed) == false }
      described_class
        .controller('Spec::NonMatchingConditionalController', if: conditional)
    end
  end

  shared_context 'with a matching conditional controller' do
    example_class 'Spec::MatchingConditionalController',
      base_class: Ephesus::Core::Controller

    before(:example) do
      conditional = ->(state) { state.get(:location) == :runway }
      described_class
        .controller('Spec::MatchingConditionalController', if: conditional)
    end
  end

  shared_context 'with a non-conditional controller' do
    example_class 'Spec::NonConditionalController',
      base_class: Ephesus::Core::Controller

    before(:example) do
      described_class.controller('Spec::NonConditionalController')
    end
  end

  shared_context 'with a session subclass' do
    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleSession', base_class: Ephesus::Core::Session
    # rubocop:enable RSpec/DescribedClass

    let(:described_class) { Spec::ExampleSession }
  end

  subject(:instance) { described_class.new(application) }

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { Spec::ExampleRepository.new }
  let(:initial_state) do
    {
      landed:   true,
      location: :runway
    }
  end
  let(:application) do
    Spec::Application.new(
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  example_class 'Spec::Application',
    base_class: Ephesus::Core::Application \
  do |klass|
    hsh = initial_state
    klass.define_method(:initial_state) { hsh }
  end

  example_class 'Spec::ExampleRepository' do |klass|
    klass.send(:include, Bronze::Collections::Repository)
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '::controller' do
    let(:error_message) do
      "unknown controller for state #{application.state.inspect}"
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:controller)
        .with(1).argument
        .and_keywords(:if, :unless)
    end

    describe 'with a controller class and no conditions' do
      include_context 'with a session subclass'

      let(:controller_class) { Spec::ExampleController }
      let(:controller_type)  { controller_class }

      example_class 'Spec::ExampleController',
        base_class: Ephesus::Core::Controller

      it 'should set the current controller' do
        described_class.controller(controller_type)

        expect(instance.controller).to be_a controller_class
      end

      wrap_context 'with a non-matching conditional controller' do
        it 'should set the current controller' do
          described_class.controller(controller_type)

          expect(instance.controller).to be_a controller_class
        end
      end

      wrap_context 'with a matching conditional controller' do
        it 'should not change the current controller' do
          described_class.controller(controller_type)

          expect(instance.controller)
            .to be_a Spec::MatchingConditionalController
        end
      end

      wrap_context 'with a non-conditional controller' do
        it 'should not change the current controller' do
          described_class.controller(controller_type)

          expect(instance.controller)
            .to be_a Spec::NonConditionalController
        end
      end

      wrap_context 'with a chain of controllers' do
        it 'should not change the current controller' do
          described_class.controller(controller_type)

          expect(instance.controller)
            .to be_a Spec::MatchingConditionalController
        end
      end
    end

    describe 'with a controller class name and no conditions' do
      include_context 'with a session subclass'

      let(:controller_class) { Spec::ExampleController }
      let(:controller_type)  { controller_class.name }

      example_class 'Spec::ExampleController',
        base_class: Ephesus::Core::Controller

      it 'should set the current controller' do
        described_class.controller(controller_type)

        expect(instance.controller).to be_a controller_class
      end

      wrap_context 'with a non-matching conditional controller' do
        it 'should set the current controller' do
          described_class.controller(controller_type)

          expect(instance.controller).to be_a controller_class
        end
      end

      wrap_context 'with a matching conditional controller' do
        it 'should not change the current controller' do
          described_class.controller(controller_type)

          expect(instance.controller)
            .to be_a Spec::MatchingConditionalController
        end
      end

      wrap_context 'with a non-conditional controller' do
        it 'should not change the current controller' do
          described_class.controller(controller_type)

          expect(instance.controller)
            .to be_a Spec::NonConditionalController
        end
      end

      wrap_context 'with a chain of controllers' do
        it 'should not change the current controller' do
          described_class.controller(controller_type)

          expect(instance.controller)
            .to be_a Spec::MatchingConditionalController
        end
      end
    end

    # rubocop:disable RSpec/NestedGroups
    describe 'with a controller class and an :if conditional' do
      include_context 'with a session subclass'

      let(:controller_class) { Spec::ExampleController }
      let(:controller_type)  { controller_class }

      example_class 'Spec::ExampleController',
        base_class: Ephesus::Core::Controller

      it 'should yield the state to the conditional block' do
        called_with = []
        conditional = ->(state) { called_with << state }

        described_class.controller(controller_type, if: conditional)

        instance.controller

        expect(called_with).to contain_exactly(application.state)
      end

      context 'when the conditional does not match the state' do
        it 'should raise an error' do
          conditional = ->(state) { state.get(:location) == :control_tower }
          described_class.controller(controller_type, if: conditional)

          expect { instance.controller }
            .to raise_error NotImplementedError, error_message
        end
      end

      context 'when the conditional matches the state' do
        it 'should set the current controller' do
          conditional = ->(state) { state.get(:landed) }
          described_class.controller(controller_type, if: conditional)

          expect(instance.controller).to be_a controller_class
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    # rubocop:disable RSpec/NestedGroups
    describe 'with a controller class name and an :if conditional' do
      include_context 'with a session subclass'

      let(:controller_class) { Spec::ExampleController }
      let(:controller_type)  { controller_class.name }

      example_class 'Spec::ExampleController',
        base_class: Ephesus::Core::Controller

      it 'should yield the state to the conditional block' do
        called_with = []
        conditional = ->(state) { called_with << state }

        described_class.controller(controller_type, if: conditional)

        instance.controller

        expect(called_with).to contain_exactly(application.state)
      end

      context 'when the conditional does not match the state' do
        it 'should raise an error' do
          conditional = ->(state) { state.get(:location) == :control_tower }
          described_class.controller(controller_type, if: conditional)

          expect { instance.controller }
            .to raise_error NotImplementedError, error_message
        end
      end

      context 'when the conditional matches the state' do
        it 'should set the current controller' do
          conditional = ->(state) { state.get(:landed) }
          described_class.controller(controller_type, if: conditional)

          expect(instance.controller).to be_a controller_class
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    # rubocop:disable RSpec/NestedGroups
    describe 'with a controller class and an :unless conditional' do
      include_context 'with a session subclass'

      let(:controller_class) { Spec::ExampleController }
      let(:controller_type)  { controller_class }

      example_class 'Spec::ExampleController',
        base_class: Ephesus::Core::Controller

      # rubocop:disable RSpec/ExampleLength
      it 'should yield the state to the conditional block' do
        called_with = []
        conditional = ->(state) { called_with << state }

        described_class.controller(controller_type, unless: conditional)

        # rubocop:disable Lint/HandleExceptions
        begin
          instance.controller
        rescue NotImplementedError
        end
        # rubocop:enable Lint/HandleExceptions

        expect(called_with).to contain_exactly(application.state)
      end
      # rubocop:enable RSpec/ExampleLength

      context 'when the conditional does not match the state' do
        it 'should set the current controller' do
          conditional = ->(state) { state.get(:location) == :control_tower }
          described_class.controller(controller_type, unless: conditional)

          expect(instance.controller).to be_a controller_class
        end
      end

      context 'when the conditional matches the state' do
        it 'should raise an error' do
          conditional = ->(state) { state.get(:landed) }
          described_class.controller(controller_type, unless: conditional)

          expect { instance.controller }
            .to raise_error NotImplementedError, error_message
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups

    # rubocop:disable RSpec/NestedGroups
    describe 'with a controller class name and an :unless conditional' do
      include_context 'with a session subclass'

      let(:controller_class) { Spec::ExampleController }
      let(:controller_type)  { controller_class.name }

      example_class 'Spec::ExampleController',
        base_class: Ephesus::Core::Controller

      # rubocop:disable RSpec/ExampleLength
      it 'should yield the state to the conditional block' do
        called_with = []
        conditional = ->(state) { called_with << state }

        described_class.controller(controller_type, unless: conditional)

        # rubocop:disable Lint/HandleExceptions
        begin
          instance.controller
        rescue NotImplementedError
        end
        # rubocop:enable Lint/HandleExceptions

        expect(called_with).to contain_exactly(application.state)
      end
      # rubocop:enable RSpec/ExampleLength

      context 'when the conditional does not match the state' do
        it 'should set the current controller' do
          conditional = ->(state) { state.get(:location) == :control_tower }
          described_class.controller(controller_type, unless: conditional)

          expect(instance.controller).to be_a controller_class
        end
      end

      context 'when the conditional matches the state' do
        it 'should raise an error' do
          conditional = ->(state) { state.get(:landed) }
          described_class.controller(controller_type, unless: conditional)

          expect { instance.controller }
            .to raise_error NotImplementedError, error_message
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  describe '#application' do
    include_examples 'should have reader', :application, -> { application }
  end

  describe '#available_actions' do
    it { expect(instance).to respond_to(:available_actions).with(0).arguments }

    wrap_context 'with a non-conditional controller' do
      include_context 'with a session subclass'

      let(:actions) do
        {
          build: {},
          fly:   {},
          dream: {}
        }
      end

      before(:example) do
        allow(instance.controller)
          .to receive(:available_actions)
          .and_return(actions)
      end

      it { expect(instance.available_actions).to be actions }

      it 'should delegate to the controller' do
        instance.available_actions

        expect(instance.controller)
          .to have_received(:available_actions)
          .with(no_args)
      end
    end
  end

  describe '#controller' do
    let(:error_message) do
      "unknown controller for state #{application.state.inspect}"
    end

    include_examples 'should have reader', :controller

    it 'should raise an error' do
      expect { instance.controller }
        .to raise_error NotImplementedError, error_message
    end

    context 'with a custom #current_controller implementation' do
      include_context 'with a session subclass'

      let(:initial_state) do
        super().merge(controller: 'Spec::CustomController')
      end
      let(:controller) { instance.controller }

      example_class 'Spec::CustomController',
        base_class: Ephesus::Core::Controller

      before(:example) do
        described_class.send(:define_method, :current_controller) do
          store.state.get(:controller)
        end
      end

      it { expect(controller).to be_a Spec::CustomController }

      it { expect(controller.event_dispatcher).to be event_dispatcher }

      it { expect(controller.repository).to be repository }

      it { expect(controller.state).to be application.state }
    end

    wrap_context 'with a non-matching conditional controller' do
      include_context 'with a session subclass'

      it 'should raise an error' do
        expect { instance.controller }
          .to raise_error NotImplementedError, error_message
      end
    end

    wrap_context 'with a matching conditional controller' do
      include_context 'with a session subclass'

      let(:controller) { instance.controller }

      it { expect(controller).to be_a Spec::MatchingConditionalController }

      it { expect(controller.event_dispatcher).to be event_dispatcher }

      it { expect(controller.repository).to be repository }

      it { expect(controller.state).to be application.state }
    end

    wrap_context 'with a non-conditional controller' do
      include_context 'with a session subclass'

      let(:controller) { instance.controller }

      it { expect(controller).to be_a Spec::NonConditionalController }

      it { expect(controller.event_dispatcher).to be event_dispatcher }

      it { expect(controller.repository).to be repository }

      it { expect(controller.state).to be application.state }
    end

    wrap_context 'with a chain of controllers' do
      include_context 'with a session subclass'

      let(:controller) { instance.controller }

      it { expect(controller).to be_a Spec::MatchingConditionalController }

      it { expect(controller.event_dispatcher).to be event_dispatcher }

      it { expect(controller.repository).to be repository }

      it { expect(controller.state).to be application.state }
    end
  end

  describe '#event_dispatcher' do
    include_examples 'should have reader',
      :event_dispatcher,
      -> { event_dispatcher }
  end

  describe '#execute_action' do
    it 'should define the method' do
      expect(instance).to respond_to(:execute_action).with(1..2).arguments
    end

    wrap_context 'with a non-conditional controller' do
      include_context 'with a session subclass'

      let(:action_name)   { :custom_action }
      let(:action_params) { { opt: 'value' } }

      before(:example) do
        allow(instance.controller).to receive(:execute_action)
      end

      it 'should delegate to the controller' do
        instance.execute_action(action_name, **action_params)

        expect(instance.controller)
          .to have_received(:execute_action)
          .with(action_name, action_params)
      end
    end
  end

  describe '#store' do
    include_examples 'should have reader', :store, -> { application.store }
  end
end
