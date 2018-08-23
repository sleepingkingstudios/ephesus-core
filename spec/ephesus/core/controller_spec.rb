# frozen_string_literal: true

require 'bronze/entities/entity'

require 'ephesus/core/action'
require 'ephesus/core/controller'
require 'ephesus/core/event_dispatcher'

RSpec.describe Ephesus::Core::Controller do
  shared_context 'when the #build_context method is defined' do
    let(:keywords) { defined?(super()) ? super() : {} }
    let(:context)  { Spec::ExampleContext.new(keywords) }

    example_class 'Spec::ExampleContext', base_class: Bronze::Entities::Entity

    before(:example) do
      # rubocop:disable RSpec/SubjectStub
      allow(instance).to receive(:build_context).and_return(context)
      # rubocop:enable RSpec/SubjectStub
    end
  end

  shared_context 'when an action is defined' do
    include_context 'when the controller has a context'

    let(:described_class) { Spec::ExampleController }
    let(:action_name)     { :do_something }
    let(:action_class)    { Spec::ExampleAction }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleController',
      base_class: Ephesus::Core::Controller
    # rubocop:enable RSpec/DescribedClass

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
      do |context, *rest, event_dispatcher:|
        super(context, event_dispatcher: event_dispatcher)

        @rest = *rest
      end

      klass.attr_reader :rest
    end
  end

  shared_context 'when the controller has a context' do
    include_context 'when the #build_context method is defined'

    before(:example) { instance.start(keywords) }
  end

  subject(:instance) do
    described_class.new(event_dispatcher: event_dispatcher)
  end

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:event_dispatcher)
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

        it { expect(action.context).to be context }

        it { expect(action.event_dispatcher).to be event_dispatcher }

        wrap_context 'when the action takes arguments' do
          let(:args)   { [:ichi, 'ni', san: 3] }
          let(:action) { instance.send action_name, *args }

          it { expect(instance).to respond_to(action_name) }

          it { expect(action).to be_a action_class }

          it { expect(action.context).to be context }

          it { expect(action.rest).to be == args }

          it { expect(action.event_dispatcher).to be event_dispatcher }
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

  describe '#context' do
    include_examples 'should have reader', :context, nil

    wrap_context 'when the controller has a context' do
      it { expect(instance.context).to be context }
    end
  end

  describe '#event_dispatcher' do
    include_examples 'should have reader',
      :event_dispatcher,
      -> { event_dispatcher }
  end

  describe '#execute_action' do
    let(:error_message) { 'controller does not have a context' }

    it 'should define the method' do
      expect(instance)
        .to respond_to(:execute_action)
        .with(1).argument
        .and_unlimited_arguments
    end

    it 'should raise an error' do
      expect { instance.execute_action(:action_name) }
        .to raise_error RuntimeError, error_message
    end

    wrap_context 'when the controller has a context' do
      describe 'with an invalid action name' do
        let(:invalid_name)  { :defenestrate }
        let(:error_message) { "invalid action name #{invalid_name.inspect}" }

        it 'should raise an error' do
          expect { instance.execute_action(invalid_name) }
            .to raise_error ArgumentError, error_message
        end
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
          action_class.new(context, event_dispatcher: event_dispatcher)
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
            action_class.new(context, event_dispatcher: event_dispatcher)
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

  describe '#start' do
    let(:error_message) { 'override #build_context in Controller subclasses' }

    it 'should define the method' do
      expect(instance).to respond_to(:start).with(0).arguments.and_any_keywords
    end

    it 'should raise an error' do
      expect { instance.start }
        .to raise_error NotImplementedError, error_message
    end

    wrap_context 'when the #build_context method is defined' do
      describe 'with no keywords' do
        it { expect(instance.start).to be instance }

        it 'should delegate to #build_context' do
          instance.start

          expect(instance).to have_received(:build_context).with({})
        end

        it 'should set the #context' do
          expect { instance.start }
            .to change(instance, :context)
            .to be context
        end
      end

      describe 'with many keywords' do
        let(:keywords) do
          {
            luck:           0.1,
            skill:          0.2,
            power_and_will: 0.15,
            pleasure:       0.05,
            pain:           0.5
          }
        end

        it { expect(instance.start(**keywords)).to be instance }

        it 'should delegate to #build_context' do
          instance.start(**keywords)

          expect(instance).to have_received(:build_context).with(keywords)
        end

        it 'should set the #context' do
          expect { instance.start }
            .to change(instance, :context)
            .to be context
        end
      end
    end

    wrap_context 'when the controller has a context' do
      let(:error_message) { 'controller already has a context' }

      it 'should raise an error' do
        expect { instance.start }
          .to raise_error RuntimeError, error_message
      end
    end
  end
end
