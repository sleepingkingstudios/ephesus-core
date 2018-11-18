# frozen_string_literal: true

require 'ephesus/core/rspec/examples/controller_examples'

require 'support/file_helpers'

RSpec.describe Ephesus::Core::RSpec::Examples::ControllerExamples do
  shared_context 'when a spec file is defined' do
    def relative_path
      Spec::Support::FileHelpers.file_path_for_example_group(self) + '_spec.rb'
    end

    before(:context) do # rubocop:disable RSpec/BeforeAfterAll
      Spec::Support::FileHelpers.write_temp_file relative_path, spec_file
    end
  end

  shared_context 'when the spec is run' do
    let(:output) { @output } # rubocop:disable RSpec/InstanceVariable

    before(:context) do # rubocop:disable RSpec/BeforeAfterAll
      spec_file_path = Spec::Support::FileHelpers.temp_file_path(relative_path)
      coverage_name  = "RSpec:#{Digest::MD5.hexdigest spec_file_path}"
      env            = "COVERAGE_COMMAND_NAME=#{coverage_name}"
      @output        = `#{env} bundle exec rspec #{spec_file_path}`
    end
  end

  def strip_object_ids(string)
    string.gsub(/:0x[0-9a-z]{16}/, '')
  end

  describe '"should define command"' do
    context 'when there are no commands defined' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller; end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should define command',
              :do_something,
              Spec::ExampleCommand
          end
        RUBY
      end

      it { expect(output).to include '4 examples, 1 failure, 3 pending' }

      it 'should not respond to #do_something' do
        failure_message = <<-MESSAGE
     Failure/Error: it { expect(instance).to respond_to(command_name).with(0).arguments }
       expected #<Spec::ExampleController> to respond to :do_something, but #<Spec::ExampleController> does not respond to :do_something
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should not define the command' do
        failure_message = <<-MESSAGE
     # Controller does not define command :do_something
     Failure/Error: expect(instance.send(command_name)).to be_a command_class

     NoMethodError:
       undefined method `do_something' for #<Spec::ExampleController>
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'should not set the command dispatcher' do
        failure_message = <<-MESSAGE
     # Controller does not define command :do_something
     Failure/Error: expect(instance.send(command_name).dispatcher).to be dispatcher

     NoMethodError:
       undefined method `do_something' for #<Spec::ExampleController>
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'should not set the command state' do
        failure_message = <<-MESSAGE
     # Controller does not define command :do_something
     Failure/Error: expect(instance.send(command_name).state).to be state

     NoMethodError:
       undefined method `do_something' for #<Spec::ExampleController>
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with an invalid command name' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller
            command :do_something, Spec::ExampleCommand
          end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should define command',
              :do_nothing,
              Spec::ExampleCommand
          end
        RUBY
      end

      it { expect(output).to include '4 examples, 1 failure, 3 pending' }

      it 'should not respond to #do_nothing' do
        failure_message = <<-MESSAGE
     Failure/Error: it { expect(instance).to respond_to(command_name).with(0).arguments }
       expected #<Spec::ExampleController> to respond to :do_nothing, but #<Spec::ExampleController> does not respond to :do_nothing
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should not define the command' do
        failure_message = <<-MESSAGE
     # Controller does not define command :do_nothing
     Failure/Error: expect(instance.send(command_name)).to be_a command_class

     NoMethodError:
       undefined method `do_nothing' for #<Spec::ExampleController>
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'should not set the command dispatcher' do
        failure_message = <<-MESSAGE
     # Controller does not define command :do_nothing
     Failure/Error: expect(instance.send(command_name).dispatcher).to be dispatcher

     NoMethodError:
       undefined method `do_nothing' for #<Spec::ExampleController>
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'should not set the command state' do
        failure_message = <<-MESSAGE
     # Controller does not define command :do_nothing
     Failure/Error: expect(instance.send(command_name).state).to be state

     NoMethodError:
       undefined method `do_nothing' for #<Spec::ExampleController>
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with an invalid command class' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::OtherCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller
            command :do_something, Spec::ExampleCommand
          end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should define command',
              :do_something,
              Spec::OtherCommand
          end
        RUBY
      end

      it { expect(output).to include '4 examples, 1 failure' }

      it 'should not define the command' do
        failure_message = <<-MESSAGE
     Failure/Error: expect(instance.send(command_name)).to be_a command_class
       expected #<Spec::ExampleCommand @state={}, @dispatcher=#<Double "dispatcher">, @options={}> to be a Spec::OtherCommand
        MESSAGE

        expect(strip_object_ids(output)).to include failure_message
      end
    end

    describe 'with a valid command name and class' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller
            command :do_something, Spec::ExampleCommand
          end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should define command',
              :do_something,
              Spec::ExampleCommand
          end
        RUBY
      end

      it { expect(output).to include '4 examples, 0 failures' }
    end
  end

  describe '"should have available command"' do
    context 'when there are no commands defined' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller; end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should have available command',
              :do_something,
              Spec::ExampleCommand
          end
        RUBY
      end

      it { expect(output).to include '1 example, 1 failure' }

      it 'should not list the command as available' do
        failure_message = <<-MESSAGE
     Failure/Error: expect(instance.available_commands.keys).to include command_name

       expected [] to include :do_something
        MESSAGE

        expect(output).to include failure_message
      end
    end

    describe 'with an invalid command name' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller
            command :do_something, Spec::ExampleCommand
          end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should have available command', :do_nothing
          end
        RUBY
      end

      it { expect(output).to include '1 example, 1 failure' }

      it 'should not list the command as available' do
        failure_message = <<-MESSAGE
     Failure/Error: expect(instance.available_commands.keys).to include command_name

       expected [:do_something] to include :do_nothing
        MESSAGE

        expect(output).to include failure_message
      end
    end

    describe 'with a valid command name' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller
            command :do_something, Spec::ExampleCommand
          end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should have available command', :do_something
          end
        RUBY
      end

      it { expect(output).to include '1 example, 0 failures' }
    end

    context 'when the command is unavailable' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller
            command :do_something, Spec::ExampleCommand, if: ->(_) { false }
          end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should have available command', :do_nothing
          end
        RUBY
      end

      it { expect(output).to include '1 example, 1 failure' }

      it 'should not list the command as available' do
        failure_message = <<-MESSAGE
     Failure/Error: expect(instance.available_commands.keys).to include command_name

       expected [] to include :do_nothing
        MESSAGE

        expect(output).to include failure_message
      end
    end

    context 'with an invalid :aliases option' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller
            command :do_something,
              Spec::ExampleCommand,
              aliases: :do_the_mario
          end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should have available command',
              :do_something,
              aliases: 'do nothing'
          end
        RUBY
      end

      it { expect(output).to include '1 example, 1 failure' }

      # rubocop:disable RSpec/ExampleLength
      it 'should not return the command properties' do
        failure_message = <<-MESSAGE
     Failure/Error: expect(instance.available_commands[command_name]).to be >= expected

       expected: >= {:aliases=>["do nothing", "do something"], :arguments=>[], :keywords=>{}}
            got:    {:aliases=>["do something", "do the mario"], :arguments=>[], :keywords=>{}}
        MESSAGE

        expect(output).to include failure_message
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'with a valid :aliases option' do
      include_context 'when a spec file is defined'
      include_context 'when the spec is run'

      def spec_file
        <<~RUBY
          # frozen_string_literal: true

          require 'spec_helper'

          require 'ephesus/core/command'
          require 'ephesus/core/controller'
          require 'ephesus/core/rspec/examples/controller_examples'

          class Spec::ExampleCommand < Ephesus::Core::Command; end

          class Spec::ExampleController < Ephesus::Core::Controller
            command :do_something,
              Spec::ExampleCommand,
              aliases: :do_the_mario
          end

          RSpec.describe Spec::ExampleController do
            include Ephesus::Core::RSpec::Examples::ControllerExamples

            subject(:instance) do
              described_class.new(state, dispatcher: dispatcher)
            end

            let(:state)      { {} }
            let(:dispatcher) { double('dispatcher') }

            include_examples 'should have available command',
              :do_something,
              aliases: 'do the mario'
          end
        RUBY
      end

      it { expect(output).to include '1 example, 0 failures' }
    end
  end
end
