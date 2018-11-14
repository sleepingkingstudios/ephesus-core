# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module ControllerExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should define command' do |command_name, command_class|
      let(:command) { instance.send(command_name) }

      it { expect(instance).to respond_to(command_name).with(0).arguments }

      it { expect(command).to be_a command_class }

      it { expect(command.state).to be state }
    end

    shared_examples 'should have available command' \
    do |command_name, command_class, **options|
      # rubocop:disable RSpec/ExampleLength
      it 'should return the command properties' do
        tools    = SleepingKingStudios::Tools::Toolbelt.instance
        name     = tools.string.underscore(command_name).tr('_', ' ')
        aliases  = [name, *options.fetch(:aliases, [])].sort
        expected = command_class.properties.merge(aliases: aliases)

        expect(instance.available_commands[command_name])
          .to be == expected
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
