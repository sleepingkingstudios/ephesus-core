# frozen_string_literal: true

require 'hamster'

require 'ephesus/core/command'
require 'ephesus/core/controller'
require 'ephesus/core/utils/dispatch_proxy'

RSpec.describe Ephesus::Core::Controller do
  shared_context 'when a command is defined' do
    include_context 'with a controller subclass'

    let(:metadata)      { {} }
    let(:command_name)  { :do_something }
    let(:command_class) { Spec::DoTheMarioCommand }
    let(:tools) do
      SleepingKingStudios::Tools::Toolbelt.instance
    end
    let(:normalized_command_name) do
      tools.string.underscore(command_name).tr('_', ' ')
    end

    example_class 'Spec::DoTheMarioCommand', base_class: Ephesus::Core::Command

    before(:example) do
      described_class.command command_name, command_class, **metadata
    end
  end

  shared_context 'when the command is secret' do
    let(:metadata) { super().merge secret: true }
  end

  shared_context 'when the controller is initialized with options' do
    let(:options) do
      {
        data:  [{}, {}, {}],
        flag:  true,
        param: 'value'
      }
    end
  end

  shared_context 'with a controller subclass' do
    let(:described_class) { Spec::ExampleController }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleController',
      base_class: Ephesus::Core::Controller
    # rubocop:enable RSpec/DescribedClass
  end

  shared_examples 'should define the constant' do
    describe '::${CommandName}' do
      before(:example) { define_command }

      it 'should define the constant' do
        expect(instance)
          .to have_constant(constant_name)
          .with_value(command_class)
      end
    end
  end

  shared_examples 'should define the helper method' do
    describe '#${command_name}' do
      before(:example) { define_command }

      def build_command
        instance.send(command_name)
      end

      it { expect(instance).to respond_to(command_name).with(0).arguments }

      it { expect(build_command).to be_a command_class }
    end
  end

  subject(:instance) do
    described_class.new(
      state,
      dispatcher: dispatcher,
      **options
    )
  end

  let(:dispatcher) do
    instance_double(Ephesus::Core::Utils::DispatchProxy)
  end
  let(:state)   { Hamster::Hash.new(landed: true, location: :hangar) }
  let(:options) { {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:dispatcher)
        .and_any_keywords
    end
  end

  describe '::command' do
    include_context 'with a controller subclass'

    let(:metadata)      { {} }
    let(:command_name)  { :do_something }
    let(:command_class) { Spec::DoTheMarioCommand }
    let(:constant_name) { tools.string.camelize(command_name) }
    let(:definition) do
      described_class.send(:command_definitions)[command_name.intern]
    end
    let(:tools) do
      SleepingKingStudios::Tools::Toolbelt.instance
    end
    let(:normalized_command_name) do
      tools.string.underscore(command_name).tr('_', ' ')
    end
    let(:expected_aliases) { [normalized_command_name] }
    let(:expected_metadata) do
      metadata
        .merge(
          aliases:    expected_aliases,
          properties: command_class.properties,
          signature:  command_class.signature
        )
    end

    example_class 'Spec::DoTheMarioCommand', base_class: Ephesus::Core::Command

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:command)
        .with(2).arguments
        .and_any_keywords
    end

    describe 'with an invalid command class' do
      let(:command_class) { Cuprum::Command }
      let(:error_message) do
        'expected command class to be a subclass of Ephesus::Core::Command, ' \
        "but was #{command_class.inspect}"
      end

      it 'should raise an error' do
        expect { described_class.command(command_name, command_class) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a name and a command class' do
      def define_command
        described_class.command(command_name, command_class)
      end

      include_examples 'should define the constant'

      include_examples 'should define the helper method'

      it 'should set the definition' do
        define_command

        expect(definition).to be_a Hash
      end

      it 'should set the class definition' do
        define_command

        expect(definition[:__const_defn__]).to be command_class
      end

      it 'should set the metadata' do
        define_command

        expect(definition.reject { |k, _| k == :__const_defn__ })
          .to be == expected_metadata
      end
    end

    describe 'with a name, a command class, and metadata' do
      let(:metadata) { { key: 'value', opt: 5 } }

      def define_command
        described_class.command(command_name, command_class, **metadata)
      end

      include_examples 'should define the constant'

      include_examples 'should define the helper method'

      it 'should set the definition' do
        define_command

        expect(definition).to be_a Hash
      end

      it 'should set the class definition' do
        define_command

        expect(definition[:__const_defn__]).to be command_class
      end

      it 'should set the metadata' do
        define_command

        expect(definition.reject { |k, _| k == :__const_defn__ })
          .to be == expected_metadata
      end

      describe 'with aliases: []' do # rubocop:disable RSpec/NestedGroups
        let(:metadata) { super().merge aliases: [:do_the_thing, 'DoTheMario'] }
        let(:expected_aliases) do
          [normalized_command_name, 'do the thing', 'do the mario'].sort
        end

        it 'should set the metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ })
            .to be == expected_metadata
        end
      end
    end
  end

  describe '#available_commands' do
    include_examples 'should have reader', :available_commands

    it { expect(instance.available_commands).to be == {} }

    wrap_context 'when a command is defined' do
      let(:expected) do
        command_class.properties.merge(aliases: [normalized_command_name])
      end

      it 'should return the commands and properties' do
        expect(instance.available_commands).to be == { do_something: expected }
      end

      context 'with an if conditional' do
        let(:arguments) { [] }
        let(:metadata) do
          { if: ->(state) { arguments << state } }
        end

        it 'should yield the state to the conditional' do
          expect { instance.available_commands }
            .to change { arguments }
            .to be == [state]
        end
      end

      context 'with a non-matching :if conditional' do
        let(:metadata) do
          { if: ->(state) { state.get(:location) == :tarmac } }
        end

        it { expect(instance.available_commands).to be == {} }
      end

      context 'with a matching :if conditional' do
        let(:metadata) do
          { if: ->(state) { state.get(:landed) } }
        end

        it 'should return the commands and properties' do
          expect(instance.available_commands)
            .to be == { do_something: expected }
        end
      end

      context 'with an unless conditional' do
        let(:arguments) { [] }
        let(:metadata) do
          { unless: ->(state) { arguments << state } }
        end

        it 'should yield the state to the conditional' do
          expect { instance.available_commands }
            .to change { arguments }
            .to be == [state]
        end
      end

      context 'with a non-matching :unless conditional' do
        let(:metadata) do
          { unless: ->(state) { state.get(:location) == :tarmac } }
        end

        it 'should return the commands and properties' do
          expect(instance.available_commands)
            .to be == { do_something: expected }
        end
      end

      context 'with a matching :unless conditional' do
        let(:metadata) do
          { unless: ->(state) { state.get(:landed) } }
        end

        it { expect(instance.available_commands).to be == {} }
      end

      context 'when the command has aliases' do
        let(:aliases)  { ['do the thing', 'do the mario'] }
        let(:metadata) { super().merge aliases: aliases }
        let(:expected) do
          super().merge aliases: [normalized_command_name, *aliases].sort
        end

        it 'should return the commands and properties' do
          expect(instance.available_commands)
            .to be == { do_something: expected }
        end
      end

      context 'when the command has examples' do
        let(:examples) do
          [
            {
              command:     'do something',
              description: 'Swing your arms from side to side!',
              header:      nil
            },
            {
              command:     'do something else',
              description: 'Do the Mario!',
              header:      'Once More, With Feeling'
            }
          ]
        end
        let(:expected) { super().merge(examples: examples) }

        before(:example) do
          Spec::DoTheMarioCommand.send :example,
            '$COMMAND',
            description: 'Swing your arms from side to side!'

          Spec::DoTheMarioCommand.send :example,
            '$COMMAND else',
            description: 'Do the Mario!',
            header:      'Once More, With Feeling'
        end

        it 'should interpolate the examples with the command name' do
          expect(instance.available_commands)
            .to be == { do_something: expected }
        end
      end
    end
  end

  describe '#command?' do
    it { expect(instance).to respond_to(:command?).with(1).argument }

    it { expect(instance.command? :do_nothing).to be false }

    wrap_context 'when a command is defined' do
      it { expect(instance.command? :do_something).to be true }
    end
  end

  describe '#commands' do
    include_examples 'should have reader', :commands, []

    wrap_context 'when a command is defined' do
      it { expect(instance.commands).to include :do_something }
    end
  end

  describe '#dispatcher' do
    include_examples 'should have reader', :dispatcher, -> { dispatcher }
  end

  describe '#execute_command' do
    it 'should define the method' do
      expect(instance)
        .to respond_to(:execute_command)
        .with(1).argument
        .and_unlimited_arguments
    end

    describe 'with an invalid command name' do
      let(:invalid_name) { :defenestrate }
      let(:arguments)    { [] }
      let(:result) do
        instance.execute_command(invalid_name, *arguments)
      end
      let(:expected_error) { :invalid_command }

      it { expect(result).to be_a Ephesus::Core::Commands::Result }

      it { expect(result.command_name).to be invalid_name }

      it { expect(result.success?).to be false }

      it 'should set the errors' do
        expect(result.errors).to include(expected_error)
      end

      # rubocop:disable RSpec/NestedGroups
      describe 'with arguments' do
        let(:arguments) { [:one, :two, { three: 3 }] }

        it { expect(result.command_name).to be invalid_name }
      end
      # rubocop:enable RSpec/NestedGroups
    end

    wrap_context 'when a command is defined' do
      describe 'with an invalid command name' do
        let(:invalid_name) { :defenestrate }
        let(:arguments)    { [] }
        let(:result) do
          instance.execute_command(invalid_name, *arguments)
        end
        let(:expected_error) { :invalid_command }

        it { expect(result).to be_a Ephesus::Core::Commands::Result }

        it { expect(result.command_name).to be invalid_name }

        it { expect(result.success?).to be false }

        it 'should set the errors' do
          expect(result.errors).to include(expected_error)
        end

        # rubocop:disable RSpec/NestedGroups
        describe 'with arguments' do
          let(:arguments) { [:one, :two, { three: 3 }] }

          it { expect(result.command_name).to be invalid_name }
        end
        # rubocop:enable RSpec/NestedGroups
      end

      describe 'with a valid command name' do
        let(:expected_result) { Ephesus::Core::Commands::Result.new }
        let(:command) do
          command_class.new(state, dispatcher: dispatcher)
        end
        let(:result) { instance.execute_command(command_name) }

        before(:example) do
          allow(command_class).to receive(:new).and_return(command)

          allow(command).to receive(:call).and_return(expected_result)
        end

        it 'should call the command' do
          instance.execute_command(command_name)

          expect(command).to have_received(:call).with(no_args)
        end

        it 'should return the result' do
          expect(result).to be expected_result
        end

        it { expect(result.command_class).to be command_class.name }

        it { expect(result.command_name).to be command_name }

        it { expect(result.controller).to be == described_class.name }

        it { expect(result.arguments).to be == [] }

        it { expect(result.keywords).to be == {} }

        # rubocop:disable RSpec/NestedGroups
        describe 'with too many arguments' do
          let(:arguments) { %w[ichi ni san] }
          let(:result) do
            instance.execute_command(command_name, *arguments)
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

          it 'should not call the command' do
            instance.execute_command(command_name, *arguments)

            expect(command).not_to have_received(:call)
          end

          it { expect(result).to be_a Ephesus::Core::Commands::Result }

          it { expect(result.success?).to be false }

          it { expect(result.command_name).to be command_name }

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
            instance.execute_command(command_name, **keywords)
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

          it 'should not call the command' do
            instance.execute_command(command_name, **keywords)

            expect(command).not_to have_received(:call)
          end

          it { expect(result).to be_a Ephesus::Core::Commands::Result }

          it { expect(result.success?).to be false }

          it { expect(result.command_name).to be command_name }

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
        context 'when the command takes arguments' do
          let(:command_name)  { :do_something_else }
          let(:command_class) { Spec::ExampleCommandWithArgs }

          example_class 'Spec::ExampleCommandWithArgs',
            base_class: Ephesus::Core::Command \
          do |klass|
            klass.send :argument, :first_arg
            klass.send :argument, :second_arg
            klass.send :argument, :third_arg, required: false

            klass.send :keyword, :first_key
            klass.send :keyword, :second_key, required: true
            klass.send :keyword, :third_key
          end

          describe 'with valid arguments and keywords' do
            let(:arguments) { %w[ichi ni san] }
            let(:keywords)  { { second_key: 'value' } }
            let(:result) do
              instance.execute_command(command_name, *arguments, **keywords)
            end

            it 'should call the command' do
              instance.execute_command(command_name, *arguments, **keywords)

              expect(command)
                .to have_received(:call).with(*arguments, **keywords)
            end

            it 'should return the result' do
              expect(
                instance.execute_command(command_name, *arguments, **keywords)
              )
                .to be expected_result
            end

            it { expect(result.success?).to be true }

            it { expect(result.errors).to be_empty }

            it { expect(result.command_name).to be command_name }

            it { expect(result.arguments).to be == arguments }

            it { expect(result.keywords).to be == keywords }
          end

          describe 'with not enough arguments' do
            let(:arguments) { %w[ichi] }
            let(:keywords)  { { second_key: 'value' } }
            let(:result) do
              instance.execute_command(command_name, *arguments, **keywords)
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

            it 'should not call the command' do
              instance.execute_command(command_name, *arguments, **keywords)

              expect(command).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Commands::Result }

            it { expect(result.success?).to be false }

            it { expect(result.command_name).to be command_name }

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
              instance.execute_command(command_name, *arguments, **keywords)
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

            it 'should not call the command' do
              instance.execute_command(command_name, *arguments, **keywords)

              expect(command).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Commands::Result }

            it { expect(result.success?).to be false }

            it { expect(result.command_name).to be command_name }

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
              instance.execute_command(command_name, *arguments, **keywords)
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

            it 'should not call the command' do
              instance.execute_command(command_name, *arguments, **keywords)

              expect(command).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Commands::Result }

            it { expect(result.success?).to be false }

            it { expect(result.command_name).to be command_name }

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
              instance.execute_command(command_name, *arguments, **keywords)
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

            it 'should not call the command' do
              instance.execute_command(command_name, *arguments, **keywords)

              expect(command).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Commands::Result }

            it { expect(result.success?).to be false }

            it { expect(result.command_name).to be command_name }

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
              instance.execute_command(command_name, *arguments, **keywords)
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

            it 'should not call the command' do
              instance.execute_command(command_name, *arguments, **keywords)

              expect(command).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Commands::Result }

            it { expect(result.success?).to be false }

            it { expect(result.command_name).to be command_name }

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
          let(:result)         { instance.execute_command(command_name) }
          let(:expected_error) { :unavailable_command }

          it 'should not call the command' do
            instance.execute_command(command_name)

            expect(command).not_to have_received(:call)
          end

          it { expect(result).to be_a Ephesus::Core::Commands::Result }

          it { expect(result.command_name).to be command_name }

          it { expect(result.success?).to be false }

          it 'should set the errors' do
            expect(result.errors).to include(expected_error)
          end

          wrap_context 'when the command is secret' do
            let(:expected_error) { :invalid_command }

            it 'should not call the command' do
              instance.execute_command(command_name)

              expect(command).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Commands::Result }

            it { expect(result.command_name).to be command_name }

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

          it 'should call the command' do
            instance.execute_command(command_name)

            expect(command).to have_received(:call).with(no_args)
          end

          it 'should return the result' do
            expect(instance.execute_command(command_name)).to be expected_result
          end
        end

        describe 'with a non-matching unless conditional' do
          let(:metadata) do
            { unless: ->(state) { state.get(:location) == :tarmac } }
          end

          it 'should call the command' do
            instance.execute_command(command_name)

            expect(command).to have_received(:call).with(no_args)
          end

          it 'should return the result' do
            expect(instance.execute_command(command_name)).to be expected_result
          end
        end

        describe 'with a matching unless conditional' do
          let(:metadata) do
            { unless: ->(state) { state.get(:landed) } }
          end
          let(:result)         { instance.execute_command(command_name) }
          let(:expected_error) { :unavailable_command }

          it 'should not call the command' do
            instance.execute_command(command_name)

            expect(command).not_to have_received(:call)
          end

          it { expect(result).to be_a Ephesus::Core::Commands::Result }

          it { expect(result.command_name).to be command_name }

          it { expect(result.success?).to be false }

          it 'should set the errors' do
            expect(result.errors).to include(expected_error)
          end

          wrap_context 'when the command is secret' do
            let(:expected_error) { :invalid_command }

            it 'should not call the command' do
              instance.execute_command(command_name)

              expect(command).not_to have_received(:call)
            end

            it { expect(result).to be_a Ephesus::Core::Commands::Result }

            it { expect(result.command_name).to be command_name }

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

  describe '#options' do
    include_examples 'should have reader', :options, {}

    wrap_context 'when the controller is initialized with options' do
      it { expect(instance.options).to be == options }
    end
  end

  describe '#state' do
    include_examples 'should have reader', :state, -> { state }
  end
end
