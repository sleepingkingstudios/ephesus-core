# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module EventHandlersExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the EventHandlers methods' do
      describe '::handle_event' do
        shared_context 'with a subclass of the handler class' do
          let(:instance_class) { Spec::ExampleHandlersSubclass }

          example_constant 'Spec::ExampleHandlersSubclass' do
            Class.new(described_class)
          end
        end

        let(:event_type) { 'spec.events.custom_event' }
        let(:event)      { Ephesus::Core::Event.new(event_type) }

        def build_instance
          instance_class.new(*instance_args)
        end

        it 'should define the class method' do
          expect(described_class)
            .to respond_to(:handle_event)
            .with(1..2)
            .arguments.and_a_block
        end

        describe 'with a block' do
          context 'with no instances' do
            it 'should not call the block' do
              expect do |block|
                described_class.handle_event(event_type, &block)

                event_dispatcher.dispatch_event(event)
              end
                .not_to yield_control
            end
          end

          context 'with one instance' do
            # rubocop:disable RSpec/ExampleLength
            it 'should call the block with the event' do
              expect do |block|
                described_class.handle_event(event_type, &block)

                build_instance

                event_dispatcher.dispatch_event(event)
              end
                .to yield_with_args(event)
            end
            # rubocop:enable RSpec/ExampleLength
          end

          context 'with many instances' do
            # rubocop:disable RSpec/ExampleLength
            it 'should call the block once per instance' do
              expect do |block|
                described_class.handle_event(event_type, &block)

                3.times { build_instance }

                event_dispatcher.dispatch_event(event)
              end
                .to yield_control.exactly(3).times
            end
            # rubocop:enable RSpec/ExampleLength
          end

          context 'when the block references an instance method' do
            let(:method_name) { :custom_event_handler }
            let(:instance)    { build_instance }

            before(:example) do
              described_class.define_method(method_name) {}
            end

            # rubocop:disable RSpec/ExampleLength
            it 'should call the method' do
              described_class.handle_event(event_type) do
                send(:custom_event_handler)
              end

              allow(instance).to receive(method_name)

              event_dispatcher.dispatch_event(event)

              expect(instance).to have_received(method_name)
            end
            # rubocop:enable RSpec/ExampleLength
          end

          wrap_context 'with a subclass of the handler class' do
            context 'with no instances' do
              it 'should not call the block' do
                expect do |block|
                  described_class.handle_event(event_type, &block)

                  event_dispatcher.dispatch_event(event)
                end
                  .not_to yield_control
              end
            end

            context 'with one instance' do
              # rubocop:disable RSpec/ExampleLength
              it 'should call the block with the event' do
                expect do |block|
                  described_class.handle_event(event_type, &block)

                  build_instance

                  event_dispatcher.dispatch_event(event)
                end
                  .to yield_with_args(event)
              end
              # rubocop:enable RSpec/ExampleLength
            end

            context 'with many instances' do
              # rubocop:disable RSpec/ExampleLength
              it 'should call the block once per instance' do
                expect do |block|
                  described_class.handle_event(event_type, &block)

                  3.times { build_instance }

                  event_dispatcher.dispatch_event(event)
                end
                  .to yield_control.exactly(3).times
              end
              # rubocop:enable RSpec/ExampleLength
            end

            context 'when the block references an instance method' do
              let(:method_name) { :custom_event_handler }
              let(:instance)    { build_instance }

              before(:example) do
                described_class.define_method(method_name) {}
              end

              # rubocop:disable RSpec/ExampleLength
              it 'should call the method' do
                described_class.handle_event(event_type) do
                  send(:custom_event_handler)
                end

                allow(instance).to receive(method_name)

                event_dispatcher.dispatch_event(event)

                expect(instance).to have_received(method_name)
              end
              # rubocop:enable RSpec/ExampleLength
            end
          end
        end

        describe 'with a method name' do
          let(:method_name) { :custom_event_handler }
          let(:instance)    { build_instance }

          before(:example) do
            described_class.define_method(:method_calls) do
              @method_calls ||= []
            end
          end

          context 'when the method is undefined' do
            let(:error_message) do
              "undefined method `#{method_name}' for class "\
              "`#{instance.class.name}'"
            end

            it 'should raise an error' do
              described_class.handle_event(event_type, method_name)

              build_instance

              expect { event_dispatcher.dispatch_event(event) }
                .to raise_error NameError, error_message
            end
          end

          context 'when the method takes no arguments' do
            # rubocop:disable RSpec/ExampleLength
            it 'should call the method with no arguments' do
              described_class.send(:define_method, method_name) do
                method_calls << nil
              end

              described_class.handle_event(event_type, method_name)

              expect { event_dispatcher.dispatch_event(event) }
                .to change(instance, :method_calls)
                .to include(nil)
            end
            # rubocop:enable RSpec/ExampleLength
          end

          context 'when the method takes an argument' do
            # rubocop:disable RSpec/ExampleLength
            it 'should call the method with the event' do
              described_class.send(:define_method, method_name) do |event|
                method_calls << event
              end

              described_class.handle_event(event_type, method_name)

              expect { event_dispatcher.dispatch_event(event) }
                .to change(instance, :method_calls)
                .to include(event)
            end
            # rubocop:enable RSpec/ExampleLength
          end

          wrap_context 'with a subclass of the handler class' do
            context 'when the method is undefined' do
              let(:error_message) do
                "undefined method `#{method_name}' for class "\
                "`#{instance.class.name}'"
              end

              it 'should raise an error' do
                described_class.handle_event(event_type, method_name)

                build_instance

                expect { event_dispatcher.dispatch_event(event) }
                  .to raise_error NameError, error_message
              end
            end

            context 'when the method takes no arguments' do
              # rubocop:disable RSpec/ExampleLength
              it 'should call the method with no arguments' do
                described_class.send(:define_method, method_name) do
                  method_calls << nil
                end

                described_class.handle_event(event_type, method_name)

                expect { event_dispatcher.dispatch_event(event) }
                  .to change(instance, :method_calls)
                  .to include(nil)
              end
              # rubocop:enable RSpec/ExampleLength
            end

            context 'when the method takes an argument' do
              # rubocop:disable RSpec/ExampleLength
              it 'should call the method with the event' do
                described_class.send(:define_method, method_name) do |event|
                  method_calls << event
                end

                described_class.handle_event(event_type, method_name)

                expect { event_dispatcher.dispatch_event(event) }
                  .to change(instance, :method_calls)
                  .to include(event)
              end
              # rubocop:enable RSpec/ExampleLength
            end
          end
        end
      end

      describe '#add_event_listener' do
        let(:event_type) { 'spec.events.custom_event' }
        let(:event)      { Ephesus::Core::Event.new(event_type) }

        it 'should define the method' do
          expect(instance)
            .to respond_to(:add_event_listener)
            .with(1).argument
            .and_a_block
        end

        describe 'with a block' do
          it 'should delegate to #event_dispatcher' do
            allow(event_dispatcher).to receive(:add_event_listener)

            instance.add_event_listener(event_type) {}

            expect(event_dispatcher)
              .to have_received(:add_event_listener)
              .with(event_type)
          end

          it 'should call the block' do
            expect do |block|
              instance.add_event_listener(event_type, &block)

              event_dispatcher.dispatch_event(event)
            end
              .to yield_control
          end
        end

        describe 'with a method name' do
          let(:method_name) { :custom_event_handler }

          it 'should delegate to #event_dispatcher' do
            allow(event_dispatcher).to receive(:add_event_listener)

            instance.add_event_listener(event_type, method_name)

            expect(event_dispatcher)
              .to have_received(:add_event_listener)
              .with(event_type)
          end

          context 'when the method is not defined' do
            let(:error_message) do
              "undefined method `#{method_name}' for class `#{described_class}'"
            end

            it 'should raise an error' do
              instance.add_event_listener(event_type, method_name)

              expect { event_dispatcher.dispatch_event(event) }
                .to raise_error NameError, error_message
            end
          end

          context 'when the method does not take any arguments' do
            it 'should call the method with no arguments' do
              called = false

              instance.define_singleton_method(method_name) { called = true }

              instance.add_event_listener(event_type, method_name)

              event_dispatcher.dispatch_event(event)

              expect(called).to be true
            end
          end

          context 'when the method takes an argument' do
            # rubocop:disable RSpec/ExampleLength
            it 'should call the method with the event' do
              arguments = []

              instance.define_singleton_method(method_name) do |*args|
                arguments = args
              end

              instance.add_event_listener(event_type, method_name)

              event_dispatcher.dispatch_event(event)

              expect(arguments).to be == [event]
            end
            # rubocop:enable RSpec/ExampleLength
          end
        end
      end

      describe '#event_dispatcher' do
        include_examples 'should have reader',
          :event_dispatcher,
          -> { event_dispatcher }
      end
    end
  end
end
