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

    shared_examples 'should have available command' \
      do |command_name, **options|
        it 'should return the command properties' do
          begin
            command  = instance.send(command_name)
            tools    = SleepingKingStudios::Tools::Toolbelt.instance
            name     = tools.string.underscore(command_name).tr('_', ' ')
            aliases  = [name, *options.fetch(:aliases, [])].sort
            expected = command.class.properties.merge(aliases: aliases)

            if options.key? :aliases
              aliases  = [name, *Array(options.fetch(:aliases))].sort
              expected = expected.merge(aliases: aliases)
            end

            expect(instance.available_commands[command_name]).to be >= expected
          rescue NoMethodError
            expect(instance.available_commands.keys).to include command_name
          end
        end
      end
  end
end
