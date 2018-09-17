# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/core/controller'
require 'ephesus/core/event_dispatcher'
require 'ephesus/core/session'

RSpec.describe Ephesus::Core::Session do
  shared_context 'when the session has a controller for the current state' do
    let(:controller_class) { Spec::Controller }

    example_class 'Spec::Controller', base_class: Ephesus::Core::Controller

    before(:example) do
      # rubocop:disable RSpec/SubjectStub
      allow(instance)
        .to receive(:controller_for)
        .with(application.state)
        .and_return(controller_class)
      # rubocop:enable RSpec/SubjectStub
    end
  end

  subject(:instance) { described_class.new(application) }

  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { Spec::ExampleRepository.new }
  let(:application) do
    Spec::Application.new(
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  example_class 'Spec::Application', base_class: Ephesus::Core::Application

  example_class 'Spec::ExampleRepository' do |klass|
    klass.send(:include, Bronze::Collections::Repository)
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#application' do
    include_examples 'should have reader', :application, -> { application }
  end

  describe '#current_controller' do
    let(:error_message) do
      "unknown controller for state #{application.state.inspect}"
    end

    include_examples 'should have reader', :current_controller

    it 'should raise an error' do
      expect { instance.current_controller }
        .to raise_error NotImplementedError, error_message
    end

    wrap_context 'when the session has a controller for the current state' do
      let(:controller) { instance.current_controller }

      it { expect(controller).to be_a controller_class }

      it { expect(controller.event_dispatcher).to be event_dispatcher }

      it { expect(controller.repository).to be repository }

      it { expect(controller.state).to be application.state }

      context 'when the current controller type is a controller class name' do
        let(:controller_class) { 'Spec::Controller' }

        it { expect(controller).to be_a Spec::Controller }
      end
    end
  end

  describe '#event_dispatcher' do
    include_examples 'should have reader',
      :event_dispatcher,
      -> { event_dispatcher }
  end

  describe '#state' do
    include_examples 'should have reader', :state, -> { application.state }
  end
end
