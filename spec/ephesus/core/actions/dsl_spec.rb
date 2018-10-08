# frozen_string_literal: true

require 'ephesus/core/action'

RSpec.describe Ephesus::Core::Actions::Dsl do
  shared_context 'when the action defines an argument' do
    before(:example) do
      action_class.send :argument, :do_something

      properties[:arguments] << {
        name:     :do_something,
        required: true
      }
    end
  end

  shared_context 'when the action defines many arguments' do
    before(:example) do
      action_class.send :argument, :argument_one
      action_class.send :argument, :argument_two,   required: true
      action_class.send :argument, :argument_three, required: false

      properties[:arguments] << {
        name:     :argument_one,
        required: true
      }

      properties[:arguments] << {
        name:     :argument_two,
        required: true
      }

      properties[:arguments] << {
        name:     :argument_three,
        required: false
      }
    end
  end

  shared_context 'when the action defines a keyword' do
    before(:example) do
      action_class.send :keyword, :with_option

      properties[:keywords][:with_option] = {
        name:     :with_option,
        required: false
      }
    end
  end

  shared_context 'when the action defines many keywords' do
    before(:example) do
      action_class.send :keyword, :keyword_one
      action_class.send :keyword, :keyword_two,   required: false
      action_class.send :keyword, :keyword_three, required: true

      properties[:keywords][:keyword_one] = {
        name:     :keyword_one,
        required: false
      }

      properties[:keywords][:keyword_two] = {
        name:     :keyword_two,
        required: false
      }

      properties[:keywords][:keyword_three] = {
        name:     :keyword_three,
        required: true
      }
    end
  end

  let(:action_class) { Class.new(Ephesus::Core::Action) }
  let(:properties) do
    {
      arguments: [],
      keywords:  {}
    }
  end

  it { expect(action_class).to be < described_class }

  describe '::argument' do
    let(:name) { :spell }
    let(:expected) do
      {
        name:     name.intern,
        required: true
      }
    end

    it { expect(action_class).not_to respond_to(:argument) }

    it 'should define the private method' do
      expect(action_class)
        .to respond_to(:argument, true)
        .with(1).argument.and_keywords(:required)
    end

    it 'should add the argument to the properties' do
      expect { action_class.send(:argument, name) }
        .to change { action_class.properties[:arguments] }
        .to include expected
    end

    describe 'with a String' do
      let(:name) { 'spell' }

      it 'should add the argument to the properties' do
        expect { action_class.send(:argument, name) }
          .to change { action_class.properties[:arguments] }
          .to include expected
      end
    end

    describe 'with a String in camel case' do
      let(:name) { 'MysticIncantation' }
      let(:expected) do
        super().tap do |hsh|
          hsh[:name] = :mystic_incantation
        end
      end

      it 'should add the argument to the properties' do
        expect { action_class.send(:argument, name) }
          .to change { action_class.properties[:arguments] }
          .to include expected
      end
    end

    describe 'with a String with whitespace' do
      let(:name) { 'eldritch invocation' }
      let(:expected) do
        super().tap do |hsh|
          hsh[:name] = :eldritch_invocation
        end
      end

      it 'should add the argument to the properties' do
        expect { action_class.send(:argument, name) }
          .to change { action_class.properties[:arguments] }
          .to include expected
      end
    end

    describe 'with required: false' do
      let(:expected) { super().merge required: false }

      it 'should add the argument to the properties' do
        expect { action_class.send(:argument, name, required: false) }
          .to change { action_class.properties[:arguments] }
          .to include expected
      end
    end

    describe 'with required: true' do
      it 'should add the argument to the properties' do
        expect { action_class.send(:argument, name, required: true) }
          .to change { action_class.properties[:arguments] }
          .to include expected
      end
    end

    wrap_context 'when the action defines an argument' do
      it 'should add the argument to the properties' do
        expect { action_class.send(:argument, name) }
          .to change { action_class.properties[:arguments] }
          .to include expected
      end
    end

    wrap_context 'when the action defines many arguments' do
      it 'should add the argument to the properties' do
        expect { action_class.send(:argument, name) }
          .to change { action_class.properties[:arguments] }
          .to include expected
      end
    end
  end

  describe '::keyword' do
    let(:name) { :target }
    let(:type) { String }
    let(:expected) do
      {
        name:     name.intern,
        required: false
      }
    end

    it { expect(action_class).not_to respond_to(:keyword) }

    it 'should define the private method' do
      expect(action_class)
        .to respond_to(:keyword, true)
        .with(1).argument.and_keywords(:required)
    end

    it 'should add the keyword to the properties' do
      expect { action_class.send(:keyword, name) }
        .to change { action_class.properties[:keywords] }
        .to include(expected[:name] => expected)
    end

    describe 'with a String' do
      let(:name) { 'target' }

      it 'should add the keyword to the properties' do
        expect { action_class.send(:keyword, name) }
          .to change { action_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    describe 'with a String in camel case' do
      let(:name) { 'AimAt' }
      let(:expected) do
        super().tap do |hsh|
          hsh[:name] = :aim_at
        end
      end

      it 'should add the keyword to the properties' do
        expect { action_class.send(:keyword, name) }
          .to change { action_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    describe 'with a String with whitespace' do
      let(:name) { 'thing wot we want to hit' }
      let(:expected) do
        super().tap do |hsh|
          hsh[:name] = :thing_wot_we_want_to_hit
        end
      end

      it 'should add the keyword to the properties' do
        expect { action_class.send(:keyword, name) }
          .to change { action_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    describe 'with required: false' do
      it 'should add the keyword to the properties' do
        expect { action_class.send(:keyword, name, required: false) }
          .to change { action_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    describe 'with required: true' do
      let(:expected) { super().merge required: true }

      it 'should add the keyword to the properties' do
        expect { action_class.send(:keyword, name, required: true) }
          .to change { action_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    wrap_context 'when the action defines a keyword' do
      it 'should add the keyword to the properties' do
        expect { action_class.send(:keyword, name) }
          .to change { action_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    wrap_context 'when the action defines many keywords' do
      it 'should add the keyword to the properties' do
        expect { action_class.send(:keyword, name) }
          .to change { action_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end
  end

  describe '::properties' do
    let(:expected) { properties }

    it { expect(action_class).to have_reader(:properties) }

    it { expect(action_class.properties).to be == expected }

    wrap_context 'when the action defines an argument' do
      it { expect(action_class.properties).to be == expected }
    end

    wrap_context 'when the action defines many arguments' do
      it { expect(action_class.properties).to be == expected }
    end

    wrap_context 'when the action defines a keyword' do
      it { expect(action_class.properties).to be == expected }
    end

    wrap_context 'when the action defines many keywords' do
      it { expect(action_class.properties).to be == expected }
    end

    context 'when the action defines many arguments and keywords' do
      include_context 'when the action defines many arguments'
      include_context 'when the action defines many keywords'

      it { expect(action_class.properties).to be == expected }
    end
  end

  describe '::signature' do
    let(:signature) { action_class.signature }

    it { expect(action_class).to have_reader(:signature) }

    it { expect(signature).to be_a Ephesus::Core::Actions::Signature }

    it { expect(signature.action_class).to be action_class }

    it { expect(signature.min_argument_count).to be 0 }

    it { expect(signature.max_argument_count).to be 0 }

    it { expect(signature.allowed_keywords).to be_empty }

    it { expect(signature.required_keywords).to be_empty }

    wrap_context 'when the action defines an argument' do
      it { expect(signature.min_argument_count).to be 1 }

      it { expect(signature.max_argument_count).to be 1 }

      it { expect(signature.allowed_keywords).to be_empty }

      it { expect(signature.required_keywords).to be_empty }
    end

    wrap_context 'when the action defines many arguments' do
      it { expect(signature.min_argument_count).to be 2 }

      it { expect(signature.max_argument_count).to be 3 }

      it { expect(signature.allowed_keywords).to be_empty }

      it { expect(signature.required_keywords).to be_empty }
    end

    wrap_context 'when the action defines a keyword' do
      it { expect(signature.min_argument_count).to be 0 }

      it { expect(signature.max_argument_count).to be 0 }

      it { expect(signature.allowed_keywords).to contain_exactly(:with_option) }

      it { expect(signature.required_keywords).to be_empty }
    end

    wrap_context 'when the action defines many keywords' do
      it { expect(signature.min_argument_count).to be 0 }

      it { expect(signature.max_argument_count).to be 0 }

      it 'should return the allowed keywords' do
        expect(signature.allowed_keywords)
          .to contain_exactly(:keyword_one, :keyword_two, :keyword_three)
      end

      it 'should return the required keywords' do
        expect(signature.required_keywords).to contain_exactly(:keyword_three)
      end
    end

    context 'when the action defines many arguments and keywords' do
      include_context 'when the action defines many arguments'
      include_context 'when the action defines many keywords'

      it { expect(signature.min_argument_count).to be 2 }

      it { expect(signature.max_argument_count).to be 3 }

      it 'should return the allowed keywords' do
        expect(signature.allowed_keywords)
          .to contain_exactly(:keyword_one, :keyword_two, :keyword_three)
      end

      it 'should return the required keywords' do
        expect(signature.required_keywords).to contain_exactly(:keyword_three)
      end
    end
  end
end
