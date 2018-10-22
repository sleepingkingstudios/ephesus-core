# frozen_string_literal: true

require 'ephesus/core/immutable_store'

RSpec.describe Ephesus::Core::ImmutableStore do
  subject(:instance) { described_class.new }

  it { expect(described_class).to be < Zinke::Store }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..2).arguments }
  end

  describe '#state' do
    shared_context 'when the store defines an initial state' do
      let(:described_class) { Spec::ExampleStore }
      let(:initial_state) do
        {
          era:      :renaissance,
          firearms: false,
          genre:    'High Fantasy'
        }
      end

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::ExampleStore', Ephesus::Core::ImmutableStore \
      do |klass|
        state = initial_state

        klass.send(:define_method, :initial_state) { state }
      end
      # rubocop:enable RSpec/DescribedClass
    end

    include_examples 'should have reader', :state

    it { expect(instance.state).to be_a Hamster::Hash }

    it { expect(instance.state).to be_empty }

    context 'when initialized with a state' do
      let(:state) do
        {
          era:   :bronze,
          magic: false,
          genre: 'Sword and Sandal'
        }
      end
      let(:instance) { described_class.new(state) }

      it { expect(instance.state).to be_a Hamster::Hash }

      it { expect(instance.state).to be == state }
    end

    wrap_context 'when the store defines an initial state' do
      it { expect(instance.state).to be_a Hamster::Hash }

      it { expect(instance.state).to be == initial_state }

      context 'when initialized with a state' do
        let(:state) do
          {
            era:   :bronze,
            magic: false,
            genre: 'Sword and Sandal'
          }
        end
        let(:instance) { described_class.new(state) }

        it { expect(instance.state).to be_a Hamster::Hash }

        it { expect(instance.state).to be == state }
      end
    end
  end
end
