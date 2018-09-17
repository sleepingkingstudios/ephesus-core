# frozen_string_literal: true

require 'bronze/collections/repository'
require 'bronze/entities/entity'

require 'ephesus/core/action'
require 'ephesus/core/controller'
require 'ephesus/core/event_dispatcher'

RSpec.describe Ephesus::Core::Controller do
  shared_context 'when an action is defined' do
    include_context 'with a controller subclass'

    let(:action_name)  { :do_something }
    let(:action_class) { Spec::ExampleAction }

    example_class 'Spec::ExampleAction', base_class: Ephesus::Core::Action

    before(:example) do
      described_class.action action_name, action_class
    end
  end

  shared_context 'when the action takes arguments' do
    let(:action_name)     { :do_something_else }
    let(:action_class)    { Spec::ExampleActionWithArgs }

    example_class 'Spec::ExampleActionWithArgs',
      base_class: Ephesus::Core::Action \
    do |klass|
      klass.send :define_method, :initialize \
      do |state, *rest, event_dispatcher:, repository: nil|
        super(
          state,
          event_dispatcher: event_dispatcher,
          repository:       repository
        )

        @arguments = *rest
      end

      klass.attr_reader :arguments
    end
  end

  shared_context 'when the controller has a repository' do
    let(:repository) { Spec::ExampleRepository.new }

    example_class 'Spec::ExampleRepository' do |klass|
      klass.send(:include, Bronze::Collections::Repository)
    end
  end

  shared_context 'with a controller subclass' do
    let(:described_class) { Spec::ExampleController }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleController',
      base_class: Ephesus::Core::Controller
    # rubocop:enable RSpec/DescribedClass
  end

  subject(:instance) do
    described_class.new(
      state,
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { nil }
  let(:state)            { Hamster::Hash.new }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:event_dispatcher, :repository)
    end
  end

  describe '::action' do
    it 'should define the class method' do
      expect(described_class).to respond_to(:action).with(2).arguments
    end

    wrap_context 'when an action is defined' do
      describe '#${action_name}' do
        let(:action) { instance.send action_name }

        it { expect(instance).to respond_to(action_name) }

        it { expect(action).to be_a action_class }

        it { expect(action.context).to be state }

        it { expect(action.event_dispatcher).to be event_dispatcher }

        it { expect(action.repository).to be nil }

        wrap_context 'when the action takes arguments' do
          let(:args)   { [:ichi, 'ni', san: 3] }
          let(:action) { instance.send action_name, *args }

          it { expect(action).to be_a action_class }

          it { expect(action.context).to be state }

          it { expect(action.arguments).to be == args }

          it { expect(action.event_dispatcher).to be event_dispatcher }

          it { expect(action.repository).to be nil }
        end

        wrap_context 'when the controller has a repository' do
          it { expect(action.repository).to be repository }
        end
      end
    end
  end

  describe '#action?' do
    it { expect(instance).to respond_to(:action?).with(1).argument }

    it { expect(instance.action? :do_nothing).to be false }

    wrap_context 'when an action is defined' do
      it { expect(instance.action? :do_something).to be true }
    end
  end

  describe '#actions' do
    include_examples 'should have reader', :actions, []

    wrap_context 'when an action is defined' do
      it { expect(instance.actions).to include :do_something }
    end
  end

  describe '#execute_action' do
    it 'should define the method' do
      expect(instance)
        .to respond_to(:execute_action)
        .with(1).argument
        .and_unlimited_arguments
    end

    describe 'with an invalid action name' do
      let(:invalid_name)  { :defenestrate }
      let(:error_message) { "invalid action name #{invalid_name.inspect}" }

      it 'should raise an error' do
        expect { instance.execute_action(invalid_name) }
          .to raise_error ArgumentError, error_message
      end
    end

    wrap_context 'when an action is defined' do
      describe 'with an invalid action name' do
        let(:invalid_name)  { :defenestrate }
        let(:error_message) { "invalid action name #{invalid_name.inspect}" }

        it 'should raise an error' do
          expect { instance.execute_action(invalid_name) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a valid action name' do
        let(:action) do
          action_class.new(state, event_dispatcher: event_dispatcher)
        end

        before(:example) do
          allow(action_class).to receive(:new).and_return(action)
        end

        it 'should call the action' do
          allow(action).to receive(:call)

          instance.execute_action(action_name)

          expect(action).to have_received(:call).with(no_args)
        end
      end

      wrap_context 'when the action takes arguments' do
        describe 'with a valid action name' do
          let(:action) do
            action_class.new(state, event_dispatcher: event_dispatcher)
          end
          let(:arguments) { [:one, :two, { three: 3 }] }

          before(:example) do
            allow(action_class).to receive(:new).and_return(action)
          end

          it 'should call the action' do
            allow(action).to receive(:call)

            instance.execute_action(action_name, *arguments)

            expect(action).to have_received(:call).with(*arguments)
          end
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

    wrap_context 'when the controller has a repository' do
      it { expect(instance.repository).to be repository }
    end
  end

  describe '#state' do
    include_examples 'should have reader', :state, -> { state }
  end
end
