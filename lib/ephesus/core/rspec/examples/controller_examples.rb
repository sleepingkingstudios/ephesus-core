# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'ephesus/core/rspec/examples'

module Ephesus::Core::RSpec::Examples
  # Defines shared examples for Ephesus controllers.
  module ControllerExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should define command' do |command_name, command_class|
      it { expect(instance).to respond_to(command_name).with(0).arguments }

      it 'should return a command instance' do
        unless instance.respond_to?(command_name)
          pending "Controller does not define command #{command_name.inspect}"
        end

        expect(instance.send(command_name)).to be_a command_class
      end

      it 'should set the command dispatcher' do
        unless instance.respond_to?(command_name)
          pending "Controller does not define command #{command_name.inspect}"
        end

        expect(instance.send(command_name).dispatcher).to be dispatcher
      end

      it 'should set the command state' do
        unless instance.respond_to?(command_name)
          pending "Controller does not define command #{command_name.inspect}"
        end

        expect(instance.send(command_name).state).to be state
      end
    end

    # rubocop:disable Metrics/BlockLength
    shared_examples 'should have available command' \
      do |command_name, **options|
        it "should include the #{command_name.inspect} command" do
          expect(instance.available_commands.keys).to include command_name
        end

        it "should include the properties for the #{command_name.inspect} " \
           'command' \
        do
          unless instance.available_commands.key?(command_name)
            pending "Command #{command_name.inspect} is not available"
          end

          properties = instance.available_commands.fetch(command_name)
          command    = instance.send(command_name)

          %w[arguments keywords description full_description].each do |p_name|
            expect(properties[p_name])
              .to be == command.class.properties[p_name]
          end
        end

        it "should return the aliases for the #{command_name} command" do
          unless instance.available_commands.key?(command_name)
            pending "Command #{command_name.inspect} is not available"
          end

          properties = instance.available_commands.fetch(command_name)
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          name       = tools.string.underscore(command_name).tr('_', ' ')
          aliases    = [name, *options.fetch(:aliases, [])].sort

          expect(properties[:aliases]).to be == aliases
        end

        it "should return the examples for the #{command_name} command" do
          unless instance.available_commands.key?(command_name)
            pending "Command #{command_name.inspect} is not available"
          end

          properties = instance.available_commands.fetch(command_name)
          command    = instance.send(command_name)
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          name       = tools.string.underscore(command_name).tr('_', ' ')
          examples   =
            command.class.properties.fetch(:examples, []).map do |hsh|
              hsh.merge(
                command: hsh[:command].gsub('$COMMAND', name)
              )
            end

          expect(properties[:examples]).to be == examples
        end
      end
    # rubocop:enable Metrics/BlockLength
  end
end
