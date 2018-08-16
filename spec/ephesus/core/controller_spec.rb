# frozen_string_literal: true

require 'bronze/entities/entity'

require 'ephesus/core/controller'
require 'ephesus/core/event_dispatcher'

RSpec.describe Ephesus::Core::Controller do
  shared_context 'when an action is defined' do
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

  subject(:instance) do
    described_class.new(context, event_dispatcher: event_dispatcher)
  end

  let(:context)          { Spec::ExampleContext.new }
  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }

  example_class 'Spec::ExampleContext', base_class: Bronze::Entities::Entity

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
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
    include_examples 'should have reader', :context, -> { context }
  end

  describe '#event_dispatcher' do
    include_examples 'should have reader',
      :event_dispatcher,
      -> { event_dispatcher }
  end
end
