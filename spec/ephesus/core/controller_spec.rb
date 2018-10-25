# frozen_string_literal: true

require 'bronze/collections/repository'
require 'hamster'

require 'ephesus/core/action'
require 'ephesus/core/controller'
require 'ephesus/core/event_dispatcher'
require 'ephesus/core/utils/dispatch_proxy'

RSpec.describe Ephesus::Core::Controller do
  shared_context 'when an action is defined' do
    include_context 'with a controller subclass'

    let(:metadata)     { {} }
    let(:action_name)  { :do_something }
    let(:action_class) { Spec::ExampleAction }

    example_class 'Spec::ExampleAction', base_class: Ephesus::Core::Action

    before(:example) do
      described_class.action action_name, action_class, **metadata
    end
  end

  shared_context 'when the action is secret' do
    let(:metadata) { super().merge secret: true }
  end

  shared_context 'when the action constructor takes arguments' do
    let(:action_name)     { :do_something_else }
    let(:action_class)    { Spec::ExampleActionWithArgs }

    example_class 'Spec::ExampleActionWithArgs',
      base_class: Ephesus::Core::Action \
    do |klass|
      klass.send :define_method, :initialize \
      do |state, *rest, dispatcher:, **options|
        super(
          state,
          dispatcher: dispatcher,
          **options
        )

        @arguments = *rest
      end

      klass.attr_reader :arguments
    end
  end

  shared_context 'when the action takes arguments' do
    let(:action_name)     { :do_something_else }
    let(:action_class)    { Spec::ExampleActionWithArgs }

    example_class 'Spec::ExampleActionWithArgs',
      base_class: Ephesus::Core::Action \
    do |klass|
      klass.send :argument, :first_arg
      klass.send :argument, :second_arg
      klass.send :argument, :third_arg, required: false

      klass.send :keyword, :first_key
      klass.send :keyword, :second_key, required: true
      klass.send :keyword, :third_key
    end
  end

  shared_context 'when a command is defined' do
    include_context 'with a controller subclass'

    let(:command_name)  { :calculate_something }
    let(:command_class) { Spec::ExampleCommand }

    example_class 'Spec::ExampleCommand', base_class: Cuprum::Command

    before(:example) do
      described_class.command command_name, command_class
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
      dispatcher:       dispatcher,
      event_dispatcher: event_dispatcher,
      repository:       repository
    )
  end

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy)
  end
  let(:event_dispatcher) { Ephesus::Core::EventDispatcher.new }
  let(:repository)       { nil }
  let(:state)            { Hamster::Hash.new(landed: true, location: :hangar) }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:dispatcher, :event_dispatcher, :repository)
    end
  end

  describe '::action' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:action)
        .with(2).arguments
        .and_any_keywords
    end

    wrap_context 'when an action is defined' do
      let(:definition) do
        described_class.send(:command_definitions)[action_name.intern]
      end
      let(:expected_metadata) do
        metadata
          .merge(
            action:     true,
            properties: action_class.properties,
            signature:  action_class.signature
          )
      end

      it 'should set the definition' do
        expect(definition).to be_a Hash
      end

      it 'should not set a class definition' do
        expect(definition[:__const_defn__]).to be nil
      end

      it 'should set the metadata' do
        expect(definition.reject { |k, _| k == :__const_defn__ })
          .to be == expected_metadata
      end

      describe 'with metadata' do
        let(:metadata) { { key: 'value', opt: 5 } }

        it 'should set the definition' do
          expect(definition).to be_a Hash
        end

        it 'should not set a class definition' do
          expect(definition[:__const_defn__]).to be nil
        end

        it 'should set the metadata' do
          expect(definition.reject { |k, _| k == :__const_defn__ })
            .to be == expected_metadata
        end
      end

      describe '#${action_name}' do
        let(:action) { instance.send action_name }

        it { expect(instance).to respond_to(action_name) }

        it { expect(action).to be_a action_class }

        it { expect(action.state).to be state }

        it { expect(action.options).to be == { repository: nil } }

        wrap_context 'when the action constructor takes arguments' do
          let(:args)   { [:ichi, 'ni', san: 3] }
          let(:action) { instance.send action_name, *args }

          it { expect(action).to be_a action_class }

          it { expect(action.state).to be state }

          it { expect(action.arguments).to be == args }

          it { expect(action.options).to be == { repository: nil } }
        end

        wrap_context 'when the controller has a repository' do
          it { expect(action.options).to be == { repository: repository } }
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

    wrap_context 'when a command is defined' do
      it { expect(instance.action? :calculate_something).to be false }
    end
  end

  describe '#actions' do
    include_examples 'should have reader', :actions, []

    wrap_context 'when an action is defined' do
      it { expect(instance.actions).to include :do_something }
    end

    wrap_context 'when a command is defined' do
      it { expect(instance.actions).not_to include :calculate_something }
    end
  end

  describe '#available_actions' do
    include_examples 'should have reader', :available_actions

    it { expect(instance.available_actions).to be == {} }

    wrap_context 'when an action is defined' do
      let(:expected) { action_class.properties }

      it 'should return the actions and properties' do
        expect(instance.available_actions).to be == { do_something: expected }
      end

      context 'with an if conditional' do
        let(:arguments) { [] }
        let(:metadata) do
          { if: ->(state) { arguments << state } }
        end

        it 'should yield the state to the conditional' do
          expect { instance.available_actions }
            .to change { arguments }
            .to be == [state]
        end
      end

      context 'with a non-matching :if conditional' do
        let(:metadata) do
          { if: ->(state) { state.get(:location) == :tarmac } }
        end

        it { expect(instance.available_actions).to be == {} }
      end

      context 'with a matching :if conditional' do
        let(:metadata) do
          { if: ->(state) { state.get(:landed) } }
        end

        it 'should return the actions and properties' do
          expect(instance.available_actions).to be == { do_something: expected }
        end
      end

      context 'with an unless conditional' do
        let(:arguments) { [] }
        let(:metadata) do
          { unless: ->(state) { arguments << state } }
        end

        it 'should yield the state to the conditional' do
          expect { instance.available_actions }
            .to change { arguments }
            .to be == [state]
        end
      end

      context 'with a non-matching :unless conditional' do
        let(:metadata) do
          { unless: ->(state) { state.get(:location) == :tarmac } }
        end

        it 'should return the actions and properties' do
          expect(instance.available_actions).to be == { do_something: expected }
        end
      end

      context 'with a matching :unless conditional' do
        let(:metadata) do
          { unless: ->(state) { state.get(:landed) } }
        end

        it { expect(instance.available_actions).to be == {} }
      end
    end

    wrap_context 'when a command is defined' do
      it { expect(instance.available_actions).to be == {} }
    end
  end

  describe '#command?' do
    it { expect(instance).to respond_to(:command?).with(1).argument }

    it { expect(instance.command? :do_nothing).to be false }

    wrap_context 'when an action is defined' do
      it { expect(instance.command? :do_something).to be true }
    end

    wrap_context 'when a command is defined' do
      it { expect(instance.command? :calculate_something).to be true }
    end
  end

  describe '#commands' do
    include_examples 'should have reader', :commands, []

    wrap_context 'when an action is defined' do
      it { expect(instance.commands).to include :do_something }
    end

    wrap_context 'when a command is defined' do
      it { expect(instance.commands).to include :calculate_something }
    end
  end

  describe '#dispatcher' do
    include_examples 'should have reader', :dispatcher, -> { dispatcher }
  end

  describe '#execute_action' do
    it 'should define the method' do
      expect(instance)
        .to respond_to(:execute_action)
        .with(1).argument
        .and_unlimited_arguments
    end

    describe 'with an invalid action name' do
      let(:invalid_name) { :defenestrate }
      let(:arguments)    { [] }
      let(:result) do
        instance.execute_action(invalid_name, *arguments)
      end
      let(:expected_error) { :invalid_action }

      it { expect(result).to be_a Ephesus::Core::Actions::Result }

      it { expect(result.action_name).to be invalid_name }

      it { expect(result.success?).to be false }

      it 'should set the errors' do
        expect(result.errors).to include(expected_error)
      end

      # rubocop:disable RSpec/NestedGroups
      describe 'with arguments' do
        let(:arguments) { [:one, :two, { three: 3 }] }

        it { expect(result.action_name).to be invalid_name }
      end
      # rubocop:enable RSpec/NestedGroups
    end

    wrap_context 'when an action is defined' do
      describe 'with an invalid action name' do
        let(:invalid_name) { :defenestrate }
        let(:arguments)    { [] }
        let(:result) do
          instance.execute_action(invalid_name, *arguments)
        end
        let(:expected_error) { :invalid_action }

        it { expect(result).to be_a Ephesus::Core::Actions::Result }

        it { expect(result.action_name).to be invalid_name }

        it { expect(result.success?).to be false }

        it 'should set the errors' do
          expect(result.errors).to include(expected_error)
        end

        # rubocop:disable RSpec/NestedGroups
        describe 'with arguments' do
          let(:arguments) { [:one, :two, { three: 3 }] }

          it { expect(result.action_name).to be invalid_name }
        end
        # rubocop:enable RSpec/NestedGroups
      end

      describe 'with a valid action name' do
        let(:expected_result) { Ephesus::Core::Actions::Result.new }
        let(:action) do
          action_class.new(
            state,
            dispatcher: dispatcher,
            event_dispatcher: event_dispatcher
          )
        end
        let(:result) { instance.execute_action(action_name) }

        before(:example) do
          allow(action_class).to receive(:new).and_return(action)

          allow(action).to receive(:call).and_return(expected_result)
        end

        it 'should call the action' do
          instance.execute_action(action_name)

          expect(action).to have_received(:call).with(no_args)
        end

        it 'should return the result' do
          expect(result).to be expected_result
        end

        it { expect(result.action_name).to be action_name }

        it { expect(result.arguments).to be == [] }

        it { expect(result.keywords).to be == {} }

        # rubocop:disable RSpec/NestedGroups
        describe 'with too many arguments' do
          let(:arguments) { %w[ichi ni san] }
          let(:result) do
            instance.execute_action(action_name, *arguments)
          end
          let(:expected_error) { :invalid_arguments }
          let(:arguments_error) do
            {
              type: :too_many_arguments,
              params: {
                actual:   3,
                expected: 0
              }
            }
          end

          it 'should not call the action' do
            instance.execute_action(action_name, *arguments)

            expect(action).not_to have_received(:call)
          end

          it { expect(result).to be_a Ephesus::Core::Actions::Result }

          it { expect(result.success?).to be false }

          it { expect(result.action_name).to be action_name }

          it { expect(result.arguments).to be == arguments }

          it { expect(result.keywords).to be == {} }

          it 'should set the errors' do
            expect(result.errors).to include(expected_error)
          end

          it 'should set the arguments error' do
            expect(result.errors[:arguments]).to include(arguments_error)
          end
        end
        # rubocop:enable RSpec/NestedGroups

        # rubocop:disable RSpec/NestedGroups
        describe 'with invalid keywords' do
          let(:keywords) { { yon: 4, go: 5, roku: 6 } }
          let(:result) do
            instance.execute_action(action_name, **keywords)
          end
          let(:expected_error) { :invalid_arguments }
          let(:keywords_error) do
            {
              type: :invalid_keywords,
              params: {
                actual:   %i[yon go roku],
                expected: [],
                invalid:  %i[yon go roku]
              }
            }
          end

          it 'should not call the action' do
            instance.execute_action(action_name, **keywords)

            expect(action).not_to have_received(:call)
          end

          it { expect(result).to be_a Ephesus::Core::Actions::Result }

          it { expect(result.success?).to be false }

          it { expect(result.action_name).to be action_name }

          it { expect(result.arguments).to be == [] }

          it { expect(result.keywords).to be == keywords }

          it 'should set the errors' do
            expect(result.errors).to include(expected_error)
          end

          it 'should set the keywords error' do
            expect(result.errors[:arguments]).to include(keywords_error)
          end
        end
        # rubocop:enable RSpec/NestedGroups

        # rubocop:disable RSpec/NestedGroups
        wrap_context 'when the action takes arguments' do
          describe 'with valid arguments and keywords' do
            let(:arguments) { %w[ichi ni san] }
            let(:keywords)  { { second_key: 'value' } }
            let(:result) do
              instance.execute_action(action_name, *arguments, **keywords)
            end

            it 'should call the action' do
              instance.execute_action(action_name, *arguments, **keywords)

              expect(action)
                .to have_received(:call).with(*arguments, **keywords)
            end

            it 'should return the result' do
              expect(
                instance.execute_action(action_name, *arguments, **keywords)
              )
                .to be expected_result
            end

            it { expect(result.success?).to be true }

            it { expect(result.errors).to be_empty }

            it { expect(result.action_name).to be action_name }

            it { expect(result.arguments).to be == arguments }

            it { expect(result.keywords).to be == keywords }
          end

          describe 'with not enough arguments' do
            let(:arguments) { %w[ichi] }
            let(:keywords)  { { second_key: 'value' } }
            let(:result) do
              instance.execute_action(action_name, *arguments, **keywords)
            end
            let(:expected_error) { :invalid_arguments }
            let(:arguments_error) do
              {
                type: :not_enough_arguments,
                params: {
                  actual:   1,
                  expected: 2
                }
              }
            end

            it 'should not call the action' do
              instance.execute_action(action_name, *arguments, **keywords)

              expect(action).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Actions::Result }

            it { expect(result.success?).to be false }

            it { expect(result.action_name).to be action_name }

            it { expect(result.arguments).to be == arguments }

            it { expect(result.keywords).to be == keywords }

            it 'should set the errors' do
              expect(result.errors).to include(expected_error)
            end

            it 'should set the arguments error' do
              expect(result.errors[:arguments]).to include(arguments_error)
            end
          end

          describe 'with too many arguments' do
            let(:arguments) { %w[ichi ni san yon go roku] }
            let(:keywords)  { { second_key: 'value' } }
            let(:result) do
              instance.execute_action(action_name, *arguments, **keywords)
            end
            let(:expected_error) { :invalid_arguments }
            let(:arguments_error) do
              {
                type: :too_many_arguments,
                params: {
                  actual:   6,
                  expected: 3
                }
              }
            end

            it 'should not call the action' do
              instance.execute_action(action_name, *arguments, **keywords)

              expect(action).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Actions::Result }

            it { expect(result.success?).to be false }

            it { expect(result.action_name).to be action_name }

            it { expect(result.arguments).to be == arguments }

            it { expect(result.keywords).to be == keywords }

            it 'should set the errors' do
              expect(result.errors).to include(expected_error)
            end

            it 'should set the arguments error' do
              expect(result.errors[:arguments]).to include(arguments_error)
            end
          end

          describe 'with invalid keywords' do
            let(:arguments) { %w[ichi ni san] }
            let(:keywords)  { { second_key: 'value', yon: 4, go: 5, roku: 6 } }
            let(:result) do
              instance.execute_action(action_name, *arguments, **keywords)
            end
            let(:expected_error) { :invalid_arguments }
            let(:keywords_error) do
              {
                type: :invalid_keywords,
                params: {
                  actual:   %i[second_key yon go roku],
                  expected: %i[first_key second_key third_key],
                  invalid:  %i[yon go roku]
                }
              }
            end

            it 'should not call the action' do
              instance.execute_action(action_name, *arguments, **keywords)

              expect(action).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Actions::Result }

            it { expect(result.success?).to be false }

            it { expect(result.action_name).to be action_name }

            it { expect(result.arguments).to be == arguments }

            it { expect(result.keywords).to be == keywords }

            it 'should set the errors' do
              expect(result.errors).to include(expected_error)
            end

            it 'should set the keywords error' do
              expect(result.errors[:arguments]).to include(keywords_error)
            end
          end

          describe 'with missing keywords' do
            let(:arguments) { %w[ichi ni san] }
            let(:keywords)  { { first_key: 'value' } }
            let(:result) do
              instance.execute_action(action_name, *arguments, **keywords)
            end
            let(:expected_error) { :invalid_arguments }
            let(:keywords_error) do
              {
                type: :missing_keywords,
                params: {
                  actual:   %i[first_key],
                  expected: %i[second_key],
                  missing:  %i[second_key]
                }
              }
            end

            it 'should not call the action' do
              instance.execute_action(action_name, *arguments, **keywords)

              expect(action).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Actions::Result }

            it { expect(result.success?).to be false }

            it { expect(result.action_name).to be action_name }

            it { expect(result.arguments).to be == arguments }

            it { expect(result.keywords).to be == keywords }

            it 'should set the errors' do
              expect(result.errors).to include(expected_error)
            end

            it 'should set the keywords error' do
              expect(result.errors[:arguments]).to include(keywords_error)
            end
          end

          describe 'with too many arguments and invalid and missing keywords' \
          do
            let(:arguments) { %w[ichi ni san yon go roku] }
            let(:keywords)  { { first_key: 'value', yon: 4, go: 5, roku: 6 } }
            let(:result) do
              instance.execute_action(action_name, *arguments, **keywords)
            end
            let(:expected_error) { :invalid_arguments }
            let(:arguments_error) do
              {
                type: :too_many_arguments,
                params: {
                  actual:   6,
                  expected: 3
                }
              }
            end
            let(:invalid_keywords_error) do
              {
                type: :invalid_keywords,
                params: {
                  actual:   %i[first_key yon go roku],
                  expected: %i[first_key second_key third_key],
                  invalid:  %i[yon go roku]
                }
              }
            end
            let(:missing_keywords_error) do
              {
                type: :missing_keywords,
                params: {
                  actual:   %i[first_key yon go roku],
                  expected: %i[second_key],
                  missing:  %i[second_key]
                }
              }
            end

            it 'should not call the action' do
              instance.execute_action(action_name, *arguments, **keywords)

              expect(action).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Actions::Result }

            it { expect(result.success?).to be false }

            it { expect(result.action_name).to be action_name }

            it { expect(result.arguments).to be == arguments }

            it { expect(result.keywords).to be == keywords }

            it 'should set the errors' do
              expect(result.errors).to include(expected_error)
            end

            it 'should set the arguments error' do
              expect(result.errors[:arguments]).to include(arguments_error)
            end

            it 'should set the invalid keywords error' do
              expect(result.errors[:arguments])
                .to include(invalid_keywords_error)
            end

            it 'should set the missing keywords error' do
              expect(result.errors[:arguments])
                .to include(missing_keywords_error)
            end
          end
        end
        # rubocop:enable RSpec/NestedGroups

        # rubocop:disable RSpec/NestedGroups
        describe 'with a non-matching if conditional' do
          let(:metadata) do
            { if: ->(state) { state.get(:location) == :tarmac } }
          end
          let(:result)         { instance.execute_action(action_name) }
          let(:expected_error) { :unavailable_action }

          it 'should not call the action' do
            instance.execute_action(action_name)

            expect(action).not_to have_received(:call)
          end

          it { expect(result).to be_a Ephesus::Core::Actions::Result }

          it { expect(result.action_name).to be action_name }

          it { expect(result.success?).to be false }

          it 'should set the errors' do
            expect(result.errors).to include(expected_error)
          end

          wrap_context 'when the action is secret' do
            let(:expected_error) { :invalid_action }

            it 'should not call the action' do
              instance.execute_action(action_name)

              expect(action).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Actions::Result }

            it { expect(result.action_name).to be action_name }

            it { expect(result.success?).to be false }

            it 'should set the errors' do
              expect(result.errors).to include(expected_error)
            end
          end
        end

        describe 'with a matching if conditional' do
          let(:metadata) do
            { if: ->(state) { state.get(:landed) } }
          end

          it 'should call the action' do
            instance.execute_action(action_name)

            expect(action).to have_received(:call).with(no_args)
          end

          it 'should return the result' do
            expect(instance.execute_action(action_name)).to be expected_result
          end
        end

        describe 'with a non-matching unless conditional' do
          let(:metadata) do
            { unless: ->(state) { state.get(:location) == :tarmac } }
          end

          it 'should call the action' do
            instance.execute_action(action_name)

            expect(action).to have_received(:call).with(no_args)
          end

          it 'should return the result' do
            expect(instance.execute_action(action_name)).to be expected_result
          end
        end

        describe 'with a matching unless conditional' do
          let(:metadata) do
            { unless: ->(state) { state.get(:landed) } }
          end
          let(:result)         { instance.execute_action(action_name) }
          let(:expected_error) { :unavailable_action }

          it 'should not call the action' do
            instance.execute_action(action_name)

            expect(action).not_to have_received(:call)
          end

          it { expect(result).to be_a Ephesus::Core::Actions::Result }

          it { expect(result.action_name).to be action_name }

          it { expect(result.success?).to be false }

          it 'should set the errors' do
            expect(result.errors).to include(expected_error)
          end

          wrap_context 'when the action is secret' do
            let(:expected_error) { :invalid_action }

            it 'should not call the action' do
              instance.execute_action(action_name)

              expect(action).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Actions::Result }

            it { expect(result.action_name).to be action_name }

            it { expect(result.success?).to be false }

            it 'should set the errors' do
              expect(result.errors).to include(expected_error)
            end
          end
        end
        # rubocop:enable RSpec/NestedGroups
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
