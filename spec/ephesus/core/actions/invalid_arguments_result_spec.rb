# frozen_string_literal: true

require 'ephesus/core/actions/invalid_arguments_result'

RSpec.describe Ephesus::Core::Actions::InvalidArgumentsResult do
  subject(:instance) { described_class.new }

  let(:action_name) { :do_something }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_any_keywords
    end
  end

  describe '#action_name' do
    it { expect(instance.action_name).to be nil }

    context 'when initialized with an action name' do
      let(:instance) { described_class.new(action_name) }

      it { expect(instance.action_name).to be action_name }
    end
  end

  describe '#errors' do
    let(:expected_error) { :invalid_arguments }

    it { expect(instance.errors).to include expected_error }
  end

  describe '#failure?' do
    it { expect(instance.failure?).to be true }
  end

  describe '#success?' do
    it { expect(instance.success?).to be false }
  end
end
