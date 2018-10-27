# frozen_string_literal: true

require 'ephesus/core/commands/result'

RSpec.describe Ephesus::Core::Commands::Result do
  subject(:instance) { described_class.new(value, errors: errors) }

  let(:value)  { 'result value' }
  let(:errors) { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0..1).arguments
        .and_keywords(:command_name, :arguments, :errors, :keywords)
    end
  end

  describe '#command_name' do
    include_examples 'should have property', :command_name, nil

    context 'when initialized with an command name' do
      let(:command_name) { :do_something }
      let(:instance) do
        described_class.new(value, command_name: command_name, errors: errors)
      end

      it { expect(instance.command_name).to be command_name }
    end

    context 'when the command name is set' do
      let(:command_name) { :do_something }

      before(:example) { instance.command_name = command_name }

      it { expect(instance.command_name).to be command_name }
    end
  end

  describe '#arguments' do
    include_examples 'should have property', :arguments, []

    context 'when initialized with arguments' do
      let(:arguments) { %w[ichi ni san] }
      let(:instance) do
        described_class.new(value, arguments: arguments, errors: errors)
      end

      it { expect(instance.arguments).to be arguments }
    end

    context 'when the arguments are set' do
      let(:arguments) { %w[ichi ni san] }

      before(:example) { instance.arguments = arguments }

      it { expect(instance.arguments).to be arguments }
    end
  end

  describe '#build_errors' do
    it { expect(instance.send(:build_errors)).to be_a Bronze::Errors }

    it { expect(instance.send(:build_errors)).to be_empty }
  end

  describe '#errors' do
    include_examples 'should have reader', :errors

    it { expect(instance.errors).to be_a Bronze::Errors }

    it { expect(instance.errors).to be_empty }
  end

  describe '#failure?' do
    include_examples 'should have predicate', :failure?, false
  end

  describe '#keywords' do
    include_examples 'should have property', :keywords, -> { be == {} }

    context 'when initialized with keywords' do
      let(:keywords) { { yon: 4, go: 5, roku: 6 } }
      let(:instance) do
        described_class.new(value, keywords: keywords, errors: errors)
      end

      it { expect(instance.keywords).to be keywords }
    end

    context 'when the keywords are set' do
      let(:keywords) { { yon: 4, go: 5, roku: 6 } }

      before(:example) { instance.keywords = keywords }

      it { expect(instance.keywords).to be keywords }
    end
  end

  describe '#success?' do
    include_examples 'should have predicate', :success?, true
  end

  describe '#value' do
    include_examples 'should have reader', :value, -> { value }
  end
end
