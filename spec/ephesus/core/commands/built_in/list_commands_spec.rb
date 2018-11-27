# frozen_string_literal: true

require 'ephesus/core/commands/built_in/list_commands'

RSpec.describe Ephesus::Core::Commands::BuiltIn::ListCommands do
  subject(:instance) { described_class.new(available_commands) }

  let(:available_commands) { {} }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '::properties' do
    let(:expected) do
      {
        arguments:        [],
        description:      'List the commands that are currently available.',
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
    it { expect(instance).to respond_to(:call).with(0).arguments }

    it { expect(instance.call.success?).to be true }

    it { expect(instance.call.value).to be == [] }

    context 'when there are many available commands' do
      let(:available_commands) do
        {
          do_something_mysterious: nil,
          do_something:            { description: 'Does something, probably.' },
          do_something_else:       { description: 'Does something else.' }
        }
      end
      let(:expected) do
        [
          [
            'do something',
            'Does something, probably.'
          ],
          [
            'do something else',
            'Does something else.'
          ],
          [
            'do something mysterious',
            nil
          ]
        ]
      end

      it { expect(instance.call.value).to be == expected }
    end
  end
end
