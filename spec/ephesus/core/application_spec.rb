# frozen_string_literal: true

require 'bronze/collections/repository'

require 'ephesus/core/application'

RSpec.describe Ephesus::Core::Application do
  shared_context 'when a custom store is defined' do
    let(:store_initial_state) do
      {
        era:       :future,
        locations: ['Venus', 'the Moon', 'Mars'],
        genre:     'Space Romance'
      }
    end

    example_class 'Spec::ExampleStore', Ephesus::Core::ImmutableStore do |klass|
      state = store_initial_state

      klass.define_method(:initial_state) { Hamster::Hash.new(state) }
    end

    before(:example) do
      Spec::ExampleApplication.define_method(:build_store) do |state|
        Spec::ExampleStore.new(state)
      end
    end
  end

  shared_context 'when the #initial_state method is defined' do
    let(:initial_state) do
      {
        era:      :renaissance,
        firearms: false,
        genre:    'High Fantasy'
      }
    end

    before(:example) do
      hsh = initial_state

      Spec::ExampleApplication.define_method(:initial_state) { hsh }
    end
  end

  shared_context 'when an initial state is given' do
    let(:state) do
      {
        era:     :iron,
        faction: 'Silla',
        genre:   'Three Kingdoms'
      }
    end
  end

  shared_context 'with an application subclass' do
    let(:described_class) { Spec::ExampleApplication }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleApplication',
      base_class: Ephesus::Core::Application
    # rubocop:enable RSpec/DescribedClass
  end

  subject(:instance) do
    described_class.new(state: state)
  end

  let(:state) { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:state)
    end
  end

  describe '#store' do
    include_examples 'should have reader',
      :store,
      -> { an_instance_of Ephesus::Core::ImmutableStore }

    it { expect(instance.store.state).to be_a Hamster::Hash }

    it { expect(instance.store.state).to be_empty }

    wrap_context 'when an initial state is given' do
      it { expect(instance.store.state).to be_a Hamster::Hash }

      it { expect(instance.store.state).to be == state }
    end

    wrap_context 'when the #initial_state method is defined' do
      include_context 'with an application subclass'

      it { expect(instance.store.state).to be_a Hamster::Hash }

      it { expect(instance.store.state).to be == initial_state }

      wrap_context 'when an initial state is given' do
        it { expect(instance.store.state).to be_a Hamster::Hash }

        it { expect(instance.store.state).to be == state }
      end
    end

    wrap_context 'when a custom store is defined' do
      include_context 'with an application subclass'

      it { expect(instance.store).to be_a Spec::ExampleStore }

      it { expect(instance.store.state).to be_a Hamster::Hash }

      it { expect(instance.store.state).to be == store_initial_state }

      wrap_context 'when an initial state is given' do
        it { expect(instance.store.state).to be_a Hamster::Hash }

        it { expect(instance.store.state).to be == state }
      end

      wrap_context 'when the #initial_state method is defined' do
        it { expect(instance.store.state).to be_a Hamster::Hash }

        it { expect(instance.store.state).to be == initial_state }

        wrap_context 'when an initial state is given' do
          it { expect(instance.store.state).to be_a Hamster::Hash }

          it { expect(instance.store.state).to be == state }
        end
      end
    end
  end
end
