# frozen_string_literal: true

require 'ephesus/core/commands/built_in/command_data'

RSpec.describe Ephesus::Core::Commands::BuiltIn::CommandData do
  subject(:instance) { described_class.new(available_commands) }

  let(:available_commands) { {} }

  describe '::COMMAND_NOT_FOUND_ERROR' do
    include_examples 'should define immutable constant',
      :COMMAND_NOT_FOUND_ERROR,
      'ephesus.core.commands.command_data.command_not_found'
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '::properties' do
    let(:arguments) do
      [
        {
          description: 'The name of the command to query.',
          name:        :command,
          required:    true
        }
      ]
    end
    let(:expected) do
      {
        arguments:        arguments,
        description:      'Provides information about the requested command.',
        examples:         [],
        full_description: nil,
        keywords:         {}
      }
    end

    it { expect(described_class.properties).to be == expected }
  end

  describe '#available_commands' do
    include_examples 'should have reader',
      :available_commands,
      -> { available_commands }
  end

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(1).argument }

    describe 'with nil' do
      let(:expected_error) do
        {
          type:   described_class::COMMAND_NOT_FOUND_ERROR,
          params: { command: nil }
        }
      end

      it { expect(instance.call(nil).value).to be nil }

      it { expect(instance.call(nil).success?).to be false }

      it { expect(instance.call(nil).errors).to include expected_error }
    end

    describe 'with an invalid command name' do
      let(:expected_error) do
        {
          type:   described_class::COMMAND_NOT_FOUND_ERROR,
          params: { command: 'do nothing' }
        }
      end

      it { expect(instance.call('do nothing').value).to be nil }

      it { expect(instance.call('do nothing').success?).to be false }

      it 'should set the errors' do
        expect(instance.call('do nothing').errors).to include expected_error
      end
    end

    context 'when there are many available commands' do
      let(:available_commands) do
        {
          do_something: {
            aliases:          ['do something', 'do the mario'],
            arguments:        [],
            description:      'Does something, probably.',
            examples:         [],
            full_description: '',
            keywords:         {}
          }
        }
      end
      let(:expected) do
        available_commands
          .fetch(:do_something)
          .merge(command_name: 'do something')
      end

      # rubocop:disable RSpec/NestedGroups
      describe 'with nil' do
        let(:expected_error) do
          {
            type:   described_class::COMMAND_NOT_FOUND_ERROR,
            params: { command: nil }
          }
        end

        it { expect(instance.call(nil).value).to be nil }

        it { expect(instance.call(nil).success?).to be false }

        it { expect(instance.call(nil).errors).to include expected_error }
      end

      describe 'with an invalid command name' do
        let(:expected_error) do
          {
            type:   described_class::COMMAND_NOT_FOUND_ERROR,
            params: { command: 'do nothing' }
          }
        end

        it { expect(instance.call('do nothing').value).to be nil }

        it { expect(instance.call('do nothing').success?).to be false }

        it 'should set the errors' do
          expect(instance.call('do nothing').errors).to include expected_error
        end
      end

      describe 'with a valid command name as a symbol' do
        it { expect(instance.call(:do_something).value).to be == expected }

        it { expect(instance.call(:do_something).success?).to be true }
      end

      describe 'with a valid command name as a string' do
        it { expect(instance.call('do something').value).to be == expected }

        it { expect(instance.call('do something').success?).to be true }
      end

      describe 'with a valid command alias' do
        let(:expected) { super().merge(command_name: 'do the mario') }

        it { expect(instance.call('do the Mario').value).to be == expected }

        it { expect(instance.call('do the Mario').success?).to be true }
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end
end
