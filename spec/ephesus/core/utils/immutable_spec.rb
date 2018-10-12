# frozen_string_literal: true

require 'ephesus/core/utils/immutable'

RSpec.describe Ephesus::Core::Utils::Immutable do
  shared_context 'with a complex data structure' do
    let(:data) do
      {
        cities: [
          {
            name:     'The Free City of Caldera',
            location: 'in a volcano'
          },
          {
            name:     "Grove of Star's Light",
            location: 'probably a forest'
          },
          {
            name:     'Winterheart',
            location: 'somewhere cold'
          }
        ],
        era:   'Renaissance',
        genre: 'High Fantasy',
        magic: :high,
        spells: Set.new(
          [
            { name: 'fireball' },
            { name: 'lightning bolt' },
            { name: 'magic missile' }
          ]
        ),
        weapons: {
          bows: Set.new(%w[crossbow longbow shortbow]),
          polearms: %w[halberd pike spear],
          swords: {
            japanese: Set.new(%w[shoto daito tachi])
          }
        }
      }
    end
    let(:immutable_data) do
      Hamster::Hash.new(
        cities: Hamster::Vector.new(
          [
            Hamster::Hash.new(
              name:     'The Free City of Caldera',
              location: 'in a volcano'
            ),
            Hamster::Hash.new(
              name:     "Grove of Star's Light",
              location: 'probably a forest'
            ),
            Hamster::Hash.new(
              name:     'Winterheart',
              location: 'somewhere cold'
            )
          ]
        ),
        era:   'Renaissance',
        genre: 'High Fantasy',
        magic: :high,
        spells: Hamster::Set.new(
          [
            Hamster::Hash.new(name: 'fireball'),
            Hamster::Hash.new(name: 'lightning bolt'),
            Hamster::Hash.new(name: 'magic missile')
          ]
        ),
        weapons: Hamster::Hash.new(
          bows: Hamster::Set.new(%w[crossbow longbow shortbow]),
          polearms: Hamster::Vector.new(%w[halberd pike spear]),
          swords: Hamster::Hash.new(
            japanese: Hamster::Set.new(%w[shoto daito tachi])
          )
        )
      )
    end
  end

  describe '::dig' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:dig)
        .with(1).argument
        .and_unlimited_arguments
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.dig nil }
          .to raise_error ArgumentError,
            'argument must be an immutable data structure'
      end
    end

    describe 'with an empty hash' do
      let(:immutable) { Hamster::Hash.new }

      it { expect(described_class.dig immutable, :seven).to be nil }

      it { expect(described_class.dig immutable, :seven, 8, :nine).to be nil }
    end

    describe 'with a hash with items' do
      let(:immutable) do
        Hamster::Hash.new(
          english:  'shortsword',
          german:   'einhänder',
          japanese: 'shoto'
        )
      end
      let(:error_message) do
        'String does not have #dig method'
      end

      it { expect(described_class.dig immutable, :seven).to be nil }

      it { expect(described_class.dig immutable, :seven, 8, :nine).to be nil }

      it { expect(described_class.dig immutable, :german).to be == 'einhänder' }

      it 'should raise an error' do
        expect { described_class.dig immutable, :german, 1, :bavarian }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with a hash of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:weapons] }
      let(:error_message) do
        'Hamster::Set does not have #dig method'
      end

      it { expect(described_class.dig immutable, :seven).to be nil }

      it { expect(described_class.dig immutable, :seven, 8, :nine).to be nil }

      it 'should return the item' do
        expect(described_class.dig immutable, :swords)
          .to be == immutable[:swords]
      end

      it 'should return the nested item' do
        expect(described_class.dig immutable, :swords, :japanese)
          .to be == immutable[:swords][:japanese]
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, :swords, :japanese, 0 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with an empty set' do
      let(:immutable) { Hamster::Set.new }
      let(:error_message) do
        'Hamster::Set does not have #dig method'
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, 7 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with a set with items' do
      let(:immutable) { Hamster::Set.new(%w[one two three]) }
      let(:error_message) do
        'Hamster::Set does not have #dig method'
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, 7 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with a set of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:spells] }
      let(:error_message) do
        'Hamster::Set does not have #dig method'
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, 7 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with an empty vector' do
      let(:immutable) { Hamster::Vector.new }

      it { expect(described_class.dig immutable, 7).to be nil }

      it { expect(described_class.dig immutable, 7, :eight, 9).to be nil }
    end

    describe 'with a vector with items' do
      let(:immutable) { Hamster::Vector.new(%w[one two three]) }
      let(:error_message) do
        'String does not have #dig method'
      end

      it { expect(described_class.dig immutable, 7).to be nil }

      it { expect(described_class.dig immutable, 7, :eight, 9).to be nil }

      it { expect(described_class.dig immutable, 1).to be == 'two' }

      it 'should raise an error' do
        expect { described_class.dig immutable, 1, :two, 3 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with a vector of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:cities] }
      let(:error_message) do
        'String does not have #dig method'
      end

      it { expect(described_class.dig immutable, 7).to be nil }

      it { expect(described_class.dig immutable, 7, :eight, 9).to be nil }

      it 'should return the item' do
        expect(described_class.dig immutable, 1).to be == immutable[1]
      end

      it 'should return the nested item' do
        expect(described_class.dig immutable, 1, :name)
          .to be == immutable[1][:name]
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, 1, :name, :nickname }
          .to raise_error TypeError, error_message
      end
    end
  end

  describe '::from_object' do
    it { expect(described_class).to respond_to(:from_object).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.from_object nil).to be nil }
    end

    describe 'with a Float' do
      it { expect(described_class.from_object 5.0).to be == 5.0 }
    end

    describe 'with an Integer' do
      it { expect(described_class.from_object 3).to be 3 }
    end

    describe 'with an immutable String' do
      let(:str) { 'string' }

      it { expect(described_class.from_object str).to be str }
    end

    describe 'with a mutable String' do
      let(:str) { +'string' }

      it { expect(described_class.from_object str).to be == str }

      it { expect(described_class.from_object(str).frozen?).to be true }
    end

    describe 'with a Symbol' do
      it { expect(described_class.from_object :symbol).to be :symbol }
    end

    describe 'with an empty array' do
      it { expect(described_class.from_object []).to be_a Hamster::Vector }

      it { expect(described_class.from_object []).to be_empty }
    end

    describe 'with an array with items' do
      let(:ary)       { %w[one two three] }
      let(:immutable) { described_class.from_object ary }

      it { expect(immutable).to be_a Hamster::Vector }

      it 'should include the array items', :aggregate_failures do
        immutable.each.with_index do |item, index|
          expect(item).to be == ary[index]
        end
      end
    end

    describe 'with an array of data objects' do
      include_context 'with a complex data structure'

      let(:ary)       { data[:cities] }
      let(:immutable) { described_class.from_object ary }

      it { expect(immutable).to be_a Hamster::Vector }

      it { expect(immutable).to be == immutable_data[:cities] }

      it 'should convert the array items to immutable objects' do
        expect(immutable).to all be_a Hamster::Hash
      end

      it 'should include the array items', :aggregate_failures do
        immutable.each.with_index do |item, index|
          expect(item).to be == ary[index]
        end
      end
    end

    describe 'with an empty hash' do
      it { expect(described_class.from_object({})).to be_a Hamster::Hash }

      it { expect(described_class.from_object({})).to be_empty }
    end

    describe 'with a hash with string keys' do
      let(:hsh) do
        {
          'english'  => 'shortsword',
          'german'   => 'einhänder',
          'japanese' => 'shoto'
        }
      end
      let(:immutable) { described_class.from_object hsh }

      it { expect(immutable).to be_a Hamster::Hash }

      it 'should convert the keys to symbols', :aggregate_failures do
        immutable.each_key do |key|
          expect(key).to be_a Symbol
        end
      end

      it 'should include the hash items', :aggregate_failures do
        immutable.each do |key, value|
          expect(value).to be == hsh[key.to_s]
        end
      end
    end

    describe 'with a hash with symbol keys' do
      let(:hsh) do
        {
          english:  'shortsword',
          german:   'einhänder',
          japanese: 'shoto'
        }
      end
      let(:immutable) { described_class.from_object hsh }

      it { expect(immutable).to be_a Hamster::Hash }

      it 'should include the hash items', :aggregate_failures do
        immutable.each do |key, value|
          expect(value).to be == hsh[key]
        end
      end
    end

    describe 'with a hash of data objects' do
      include_context 'with a complex data structure'

      let(:hsh)       { data[:weapons] }
      let(:immutable) { described_class.from_object hsh }

      it { expect(immutable).to be_a Hamster::Hash }

      it { expect(immutable).to be == immutable_data[:weapons] }

      it { expect(immutable[:bows]).to be_a Hamster::Set }

      it { expect(immutable[:polearms]).to be_a Hamster::Vector }

      it { expect(immutable[:swords]).to be_a Hamster::Hash }

      it { expect(immutable[:swords][:japanese]).to be_a Hamster::Set }

      it 'should convert array items' do
        expect(immutable[:polearms]).to be == hsh[:polearms]
      end

      it 'should convert set items' do
        expect(immutable[:bows]).to contain_exactly(*hsh[:bows])
      end
    end

    describe 'with an empty set' do
      it { expect(described_class.from_object Set.new).to be_a Hamster::Set }

      it { expect(described_class.from_object Set.new).to be_empty }
    end

    describe 'with a set with items' do
      let(:set)       { Set.new(%w[one two three]) }
      let(:immutable) { described_class.from_object set }

      it { expect(immutable).to be_a Hamster::Set }

      it 'should include the set items', :aggregate_failures do
        immutable.each do |item|
          expect(set).to include item
        end
      end
    end

    describe 'with a set of data objects' do
      include_context 'with a complex data structure'

      let(:set)       { data[:spells] }
      let(:immutable) { described_class.from_object set }

      it { expect(immutable).to be_a Hamster::Set }

      it { expect(immutable).to be == immutable_data[:spells] }

      it 'should convert the set items to immutable objects' do
        expect(immutable).to all be_a Hamster::Hash
      end

      it 'should include the set items', :aggregate_failures do
        immutable.each { |item| expect(set).to include item.to_hash }
      end
    end

    describe 'with a complex data structure' do
      include_context 'with a complex data structure'

      let(:immutable) { described_class.from_object data }

      it { expect(immutable).to be_a Hamster::Hash }

      it { expect(immutable).to be == immutable_data }
    end
  end

  describe '::to_object' do
    describe 'with nil' do
      it { expect(described_class.to_object nil).to be nil }
    end

    describe 'with a Float' do
      it { expect(described_class.to_object 5.0).to be == 5.0 }
    end

    describe 'with an Integer' do
      it { expect(described_class.to_object 3).to be 3 }
    end

    describe 'with a String' do
      it { expect(described_class.from_object 'string').to be == 'string' }
    end

    describe 'with a Symbol' do
      it { expect(described_class.from_object :symbol).to be :symbol }
    end

    describe 'with an empty hash' do
      let(:immutable) { Hamster::Hash.new }
      let(:set)       { described_class.to_object immutable }

      it { expect(set).to be_a Hash }

      it { expect(set).to be_empty }
    end

    describe 'with a hash with items' do
      let(:immutable) do
        Hamster::Hash.new(
          english:  'shortsword',
          german:   'einhänder',
          japanese: 'shoto'
        )
      end
      let(:hsh) { described_class.to_object immutable }

      it { expect(hsh).to be_a Hash }

      it 'should include the hash items', :aggregate_failures do
        hsh.each do |key, value|
          expect(value).to be == immutable[key]
        end
      end
    end

    describe 'with a hash of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:weapons] }
      let(:hsh)       { described_class.to_object immutable }

      it { expect(hsh).to be_a Hash }

      it { expect(hsh).to be == data[:weapons] }

      it { expect(hsh[:bows]).to be_a Set }

      it { expect(hsh[:polearms]).to be_a Array }

      it { expect(hsh[:swords]).to be_a Hash }

      it { expect(hsh[:swords][:japanese]).to be_a Set }

      it 'should convert array items' do
        expect(hsh[:polearms]).to be == immutable[:polearms]
      end

      it 'should convert set items' do
        expect(hsh[:bows]).to contain_exactly(*immutable[:bows])
      end
    end

    describe 'with an empty set' do
      let(:immutable) { Hamster::Set.new }
      let(:set)       { described_class.to_object immutable }

      it { expect(set).to be_a Set }

      it { expect(set).to be_empty }
    end

    describe 'with a set with items' do
      let(:immutable) { Hamster::Set.new(%w[one two three]) }
      let(:set)       { described_class.to_object immutable }

      it { expect(set).to be_a Set }

      it 'should include the set items', :aggregate_failures do
        immutable.each { |item| expect(set).to include item }
      end
    end

    describe 'with a set of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:spells] }
      let(:set)       { described_class.to_object immutable }

      it { expect(set).to be_a Set }

      it { expect(set).to be == data[:spells] }

      it 'should convert the set items from immutable objects' do
        expect(set).to all be_a Hash
      end

      it 'should include the set items', :aggregate_failures do
        immutable.each { |item| expect(set).to include item.to_hash }
      end
    end

    describe 'with an empty vector' do
      let(:immutable) { Hamster::Vector.new }
      let(:ary)       { described_class.to_object immutable }

      it { expect(ary).to be_a Array }

      it { expect(ary).to be_empty }
    end

    describe 'with a vector with items' do
      let(:immutable) { Hamster::Vector.new(%w[one two three]) }
      let(:ary)       { described_class.to_object immutable }

      it { expect(ary).to be_a Array }

      it 'should include the vector items', :aggregate_failures do
        ary.each.with_index do |item, index|
          expect(item).to be == immutable[index]
        end
      end
    end

    describe 'with a vector of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:cities] }
      let(:ary)       { described_class.to_object immutable }

      it { expect(ary).to be_a Array }

      it { expect(ary).to be == data[:cities] }

      it 'should convert the vector items from immutable objects' do
        expect(ary).to all be_a Hash
      end

      it 'should include the vector items', :aggregate_failures do
        ary.each.with_index do |item, index|
          expect(item).to be == immutable[index].to_hash
        end
      end
    end

    describe 'with a complex data structure' do
      include_context 'with a complex data structure'

      let(:hsh) { described_class.to_object immutable_data }

      it { expect(hsh).to be_a Hash }

      it { expect(hsh).to be == data }
    end
  end
end
