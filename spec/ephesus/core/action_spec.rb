# frozen_string_literal: true

require 'ephesus/core/action'

RSpec.describe Ephesus::Core::Action do
  subject(:instance) { described_class.new(session) }

  let(:session) { Spec::ExampleSession.new }

  example_class 'Spec::ExampleSession'

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#build_errors' do
    it 'should create an instance of Bronze::Errors' do
      # rubocop:disable RSpec/SubjectStub
      allow(instance).to receive(:process) do
        errors = instance.send(:result).errors

        expect(errors).to be_a Bronze::Errors
      end
      # rubocop:enable RSpec/SubjectStub

      instance.call
    end
  end

  describe '#session' do
    include_examples 'should have reader', :session, -> { session }
  end
end
