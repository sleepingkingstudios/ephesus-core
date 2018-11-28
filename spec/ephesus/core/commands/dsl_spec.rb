# frozen_string_literal: true

require 'ephesus/core/command'

RSpec.describe Ephesus::Core::Commands::Dsl do
  shared_context 'when the command defines an argument' do
    before(:example) do
      description = 'Some argument, apparently.'

      Spec::ExampleCommand
        .send :argument, :some_argument, description: description

      properties[:arguments] << {
        name:        :some_argument,
        description: description,
        required:    true
      }
    end
  end

  shared_context 'when the command defines many arguments' do
    before(:example) do
      Spec::ExampleCommand.send :argument, :argument_one
      Spec::ExampleCommand.send :argument, :argument_two,   required: true
      Spec::ExampleCommand.send :argument, :argument_three, required: false

      properties[:arguments] << {
        name:        :argument_one,
        description: nil,
        required:    true
      }

      properties[:arguments] << {
        name:        :argument_two,
        description: nil,
        required:    true
      }

      properties[:arguments] << {
        name:        :argument_three,
        description: nil,
        required:    false
      }
    end
  end

  shared_context 'when the command defines a keyword' do
    before(:example) do
      description = 'An option, apparently.'

      Spec::ExampleCommand.send :keyword, :with_option, description: description

      properties[:keywords][:with_option] = {
        name:        :with_option,
        description: description,
        required:    false
      }
    end
  end

  shared_context 'when the command defines many keywords' do
    before(:example) do
      Spec::ExampleCommand.send :keyword, :keyword_one
      Spec::ExampleCommand.send :keyword, :keyword_two,   required: false
      Spec::ExampleCommand.send :keyword, :keyword_three, required: true

      properties[:keywords][:keyword_one] = {
        name:        :keyword_one,
        description: nil,
        required:    false
      }

      properties[:keywords][:keyword_two] = {
        name:        :keyword_two,
        description: nil,
        required:    false
      }

      properties[:keywords][:keyword_three] = {
        name:        :keyword_three,
        description: nil,
        required:    true
      }
    end
  end

  shared_context 'when the command has a description' do
    before(:example) do
      description = 'Definitely does something.'

      Spec::ExampleCommand.send :description, description

      properties[:description] = description
    end
  end

  shared_context 'when the command has a full description' do
    before(:example) do
      description =
        'Definitely does something. Not sure what. But something.'

      Spec::ExampleCommand.send :full_description, description

      properties[:full_description] = description
    end
  end

  shared_context 'when the command has an example' do
    before(:example) do
      command     = 'an example'
      description = 'An example description'

      Spec::ExampleCommand.send :example, command, description: description

      properties[:examples] << {
        command:     command,
        description: description,
        header:      nil
      }
    end
  end

  shared_context 'when the command has many examples' do
    before(:example) do
      Spec::ExampleCommand.send :example,
        'basic example',
        description: 'A basic example'

      Spec::ExampleCommand.send :example,
        'example with header',
        description: 'An example with a header',
        header:      'Example With Header'

      Spec::ExampleCommand.send :example,
        'another example',
        description: 'Another example',
        header:      'Another Example'

      properties[:examples] << {
        command:     'basic example',
        description: 'A basic example',
        header:      nil
      }

      properties[:examples] << {
        command:     'example with header',
        description: 'An example with a header',
        header:      'Example With Header'
      }

      properties[:examples] << {
        command:     'another example',
        description: 'Another example',
        header:      'Another Example'
      }
    end
  end

  shared_context 'when the command has many properties' do
    include_context 'when the command defines many arguments'
    include_context 'when the command defines many keywords'
    include_context 'when the command has a description'
    include_context 'when the command has a full description'
    include_context 'when the command has many examples'
  end

  shared_context 'with a subclass of the command' do
    let(:command_class) { Spec::CommandSubclass }

    example_class 'Spec::CommandSubclass', 'Spec::ExampleCommand'
  end

  shared_context 'with manually edited properties' do
    include_context 'when the command has many properties'

    before(:example) do
      Spec::ExampleCommand.instance_eval do
        properties[:arguments]
          .find { |hsh| hsh[:name] == :argument_two }
          .update(required: false)

        properties[:description] = 'Do something else.'
      end

      properties[:arguments]
        .find { |hsh| hsh[:name] == :argument_two }
        .update(required: false)

      properties[:description] = 'Do something else.'
    end
  end

  let(:command_class) { Spec::ExampleCommand }
  let(:properties)    { build_properties }

  example_class 'Spec::ExampleCommand', Ephesus::Core::Command

  def build_properties
    {
      arguments:        [],
      description:      nil,
      examples:         [],
      full_description: nil,
      keywords:         {}
    }
  end

  it { expect(command_class).to be < described_class }

  describe '::argument' do
    let(:name) { :spell }
    let(:expected) do
      {
        name:        name.intern,
        description: nil,
        required:    true
      }
    end

    it { expect(command_class).not_to respond_to(:argument) }

    it 'should define the private method' do
      expect(command_class)
        .to respond_to(:argument, true)
        .with(1).argument.and_keywords(:description, :required)
    end

    it 'should add the argument to the properties' do
      expect { command_class.send(:argument, name) }
        .to change { command_class.properties[:arguments] }
        .to include expected
    end

    describe 'with a String' do
      let(:name) { 'spell' }

      it 'should add the argument to the properties' do
        expect { command_class.send(:argument, name) }
          .to change { command_class.properties[:arguments] }
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
        expect { command_class.send(:argument, name) }
          .to change { command_class.properties[:arguments] }
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
        expect { command_class.send(:argument, name) }
          .to change { command_class.properties[:arguments] }
          .to include expected
      end
    end

    describe 'with a description' do
      let(:string)   { 'The spell to cast.' }
      let(:expected) { super().merge description: string }

      it 'should add the argument to the properties' do
        expect { command_class.send(:argument, name, description: string) }
          .to change { command_class.properties[:arguments] }
          .to include expected
      end
    end

    describe 'with required: false' do
      let(:expected) { super().merge required: false }

      it 'should add the argument to the properties' do
        expect { command_class.send(:argument, name, required: false) }
          .to change { command_class.properties[:arguments] }
          .to include expected
      end
    end

    describe 'with required: true' do
      it 'should add the argument to the properties' do
        expect { command_class.send(:argument, name, required: true) }
          .to change { command_class.properties[:arguments] }
          .to include expected
      end
    end

    wrap_context 'when the command defines an argument' do
      it 'should add the argument to the properties' do
        expect { command_class.send(:argument, name) }
          .to change { command_class.properties[:arguments] }
          .to include expected
      end
    end

    wrap_context 'when the command defines many arguments' do
      it 'should add the argument to the properties' do
        expect { command_class.send(:argument, name) }
          .to change { command_class.properties[:arguments] }
          .to include expected
      end
    end

    wrap_context 'with a subclass of the command' do
      it 'should add the argument to the properties' do
        expect { command_class.send(:argument, name) }
          .to change { command_class.properties[:arguments] }
          .to include expected
      end

      wrap_context 'when the command defines an argument' do
        it 'should not change the properties of the parent command' do
          expect { command_class.send(:argument, name) }
            .not_to change(Spec::ExampleCommand, :properties)
        end

        it 'should add the argument to the properties' do
          expect { command_class.send(:argument, name) }
            .to change { command_class.properties[:arguments] }
            .to include expected
        end
      end
    end
  end

  describe '::description' do
    let(:string) { 'Does something, probably.' }

    it { expect(command_class).not_to respond_to(:description) }

    it 'should define the private method' do
      expect(command_class)
        .to respond_to(:description, true)
        .with(1).argument
    end

    it 'should add the description to the properties' do
      expect { command_class.send(:description, string) }
        .to change { command_class.properties[:description] }
        .to be == string
    end

    wrap_context 'with a subclass of the command' do
      it 'should add the description to the properties' do
        expect { command_class.send(:description, string) }
          .to change { command_class.properties[:description] }
          .to be == string
      end

      wrap_context 'when the command has a description' do
        it 'should not change the properties of the parent command' do
          expect { command_class.send(:description, string) }
            .not_to change(Spec::ExampleCommand, :properties)
        end

        it 'should add the description to the properties' do
          expect { command_class.send(:description, string) }
            .to change { command_class.properties[:description] }
            .to be == string
        end
      end
    end
  end

  describe '::example' do
    let(:command)     { 'do something' }
    let(:description) { 'Does something.' }
    let(:expected) do
      {
        command:     command,
        header:      nil,
        description: description
      }
    end

    it { expect(command_class).not_to respond_to(:example) }

    it 'should define the private method' do
      expect(command_class)
        .to respond_to(:example, true)
        .with(1).argument.and_keywords(:description, :header)
    end

    it 'should add the example to the properties' do
      expect { command_class.send(:example, command, description: description) }
        .to change { command_class.properties[:examples] }
        .to include expected
    end

    describe 'with a header' do
      let(:header)   { 'Doing Something Else' }
      let(:expected) { super().merge header: header }

      # rubocop:disable RSpec/ExampleLength
      it 'should add the example to the properties' do
        expect do
          command_class.send(
            :example,
            command,
            description: description,
            header:      header
          )
        end
          .to change { command_class.properties[:examples] }
          .to include expected
      end
      # rubocop:enable RSpec/ExampleLength
    end

    wrap_context 'when the command has an example' do
      it 'should add the example to the properties' do
        expect do
          command_class.send(:example, command, description: description)
        end
          .to change { command_class.properties[:examples] }
          .to include expected
      end

      describe 'with a header' do
        let(:header)   { 'Doing Something Else' }
        let(:expected) { super().merge header: header }

        # rubocop:disable RSpec/ExampleLength
        it 'should add the example to the properties' do
          expect do
            command_class.send(
              :example,
              command,
              description: description,
              header:      header
            )
          end
            .to change { command_class.properties[:examples] }
            .to include expected
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end

    wrap_context 'when the command has many examples' do
      it 'should add the example to the properties' do
        expect do
          command_class.send(:example, command, description: description)
        end
          .to change { command_class.properties[:examples] }
          .to include expected
      end

      describe 'with a header' do
        let(:header)   { 'Doing Something Else' }
        let(:expected) { super().merge header: header }

        # rubocop:disable RSpec/ExampleLength
        it 'should add the example to the properties' do
          expect do
            command_class.send(
              :example,
              command,
              description: description,
              header:      header
            )
          end
            .to change { command_class.properties[:examples] }
            .to include expected
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end

    wrap_context 'with a subclass of the command' do
      it 'should add the example to the properties' do
        expect do
          command_class.send(:example, command, description: description)
        end
          .to change { command_class.properties[:examples] }
          .to include expected
      end

      wrap_context 'when the command has an example' do
        it 'should not change the properties of the parent command' do
          expect do
            command_class.send(:example, command, description: description)
          end
            .not_to change(Spec::ExampleCommand, :properties)
        end

        it 'should add the example to the properties' do
          expect do
            command_class.send(:example, command, description: description)
          end
            .to change { command_class.properties[:examples] }
            .to include expected
        end
      end
    end
  end

  describe '::full_description' do
    let(:string) do
      'Does something, probably. With a few details here and there.'
    end

    it { expect(command_class).not_to respond_to(:full_description) }

    it 'should define the private method' do
      expect(command_class)
        .to respond_to(:full_description, true)
        .with(1).argument
    end

    it 'should add the full_description to the properties' do
      expect { command_class.send(:full_description, string) }
        .to change { command_class.properties[:full_description] }
        .to be == string
    end

    wrap_context 'with a subclass of the command' do
      it 'should add the full_description to the properties' do
        expect { command_class.send(:full_description, string) }
          .to change { command_class.properties[:full_description] }
          .to be == string
      end

      wrap_context 'when the command has a full description' do
        it 'should not change the properties of the parent command' do
          expect { command_class.send(:full_description, string) }
            .not_to change(Spec::ExampleCommand, :properties)
        end

        it 'should add the full_description to the properties' do
          expect { command_class.send(:full_description, string) }
            .to change { command_class.properties[:full_description] }
            .to be == string
        end
      end
    end
  end

  describe '::keyword' do
    let(:name) { :target }
    let(:type) { String }
    let(:expected) do
      {
        name:        name.intern,
        description: nil,
        required:    false
      }
    end

    it { expect(command_class).not_to respond_to(:keyword) }

    it 'should define the private method' do
      expect(command_class)
        .to respond_to(:keyword, true)
        .with(1).argument.and_keywords(:description, :required)
    end

    it 'should add the keyword to the properties' do
      expect { command_class.send(:keyword, name) }
        .to change { command_class.properties[:keywords] }
        .to include(expected[:name] => expected)
    end

    describe 'with a String' do
      let(:name) { 'target' }

      it 'should add the keyword to the properties' do
        expect { command_class.send(:keyword, name) }
          .to change { command_class.properties[:keywords] }
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
        expect { command_class.send(:keyword, name) }
          .to change { command_class.properties[:keywords] }
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
        expect { command_class.send(:keyword, name) }
          .to change { command_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    describe 'with a description' do
      let(:string)   { 'The target of the spell.' }
      let(:expected) { super().merge description: string }

      it 'should add the argument to the properties' do
        expect { command_class.send(:keyword, name, description: string) }
          .to change { command_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    describe 'with required: false' do
      it 'should add the keyword to the properties' do
        expect { command_class.send(:keyword, name, required: false) }
          .to change { command_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    describe 'with required: true' do
      let(:expected) { super().merge required: true }

      it 'should add the keyword to the properties' do
        expect { command_class.send(:keyword, name, required: true) }
          .to change { command_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    wrap_context 'when the command defines a keyword' do
      it 'should add the keyword to the properties' do
        expect { command_class.send(:keyword, name) }
          .to change { command_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    wrap_context 'when the command defines many keywords' do
      it 'should add the keyword to the properties' do
        expect { command_class.send(:keyword, name) }
          .to change { command_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end
    end

    wrap_context 'with a subclass of the command' do
      it 'should add the keyword to the properties' do
        expect { command_class.send(:keyword, name) }
          .to change { command_class.properties[:keywords] }
          .to include(expected[:name] => expected)
      end

      wrap_context 'when the command defines a keyword' do
        it 'should not change the properties of the parent command' do
          expect { command_class.send(:keyword, name) }
            .not_to change(Spec::ExampleCommand, :properties)
        end

        it 'should add the keyword to the properties' do
          expect { command_class.send(:keyword, name) }
            .to change { command_class.properties[:keywords] }
            .to include(expected[:name] => expected)
        end
      end
    end
  end

  describe '::properties' do
    let(:expected) { properties }

    it { expect(command_class).to have_reader(:properties) }

    it { expect(command_class.properties).to be == expected }

    wrap_context 'when the command defines an argument' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'when the command defines many arguments' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'when the command defines a keyword' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'when the command defines many keywords' do
      it { expect(command_class.properties).to be == expected }
    end

    context 'when the command defines many arguments and keywords' do
      include_context 'when the command defines many arguments'
      include_context 'when the command defines many keywords'

      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'when the command has a description' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'when the command has a full description' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'when the command has an example' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'when the command has many examples' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'when the command has many properties' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'with manually edited properties' do
      it { expect(command_class.properties).to be == expected }
    end

    wrap_context 'with a subclass of the command' do
      it { expect(command_class.properties).to be == expected }

      wrap_context 'when the command defines an argument' do
        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'when the command defines many arguments' do
        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'when the command defines a keyword' do
        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'when the command defines many keywords' do
        it { expect(command_class.properties).to be == expected }
      end

      context 'when the command defines many arguments and keywords' do
        include_context 'when the command defines many arguments'
        include_context 'when the command defines many keywords'

        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'when the command has a description' do
        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'when the command has a full description' do
        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'when the command has an example' do
        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'when the command has many examples' do
        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'when the command has many properties' do
        it { expect(command_class.properties).to be == expected }
      end

      wrap_context 'with manually edited properties' do
        it { expect(command_class.properties).to be == expected }
      end
    end
  end

  describe '::signature' do
    let(:signature) { command_class.signature }

    it { expect(command_class).to have_reader(:signature) }

    it { expect(signature).to be_a Ephesus::Core::Commands::Signature }

    it { expect(signature.command_class).to be command_class }

    it { expect(signature.min_argument_count).to be 0 }

    it { expect(signature.max_argument_count).to be 0 }

    it { expect(signature.allowed_keywords).to be_empty }

    it { expect(signature.required_keywords).to be_empty }

    wrap_context 'when the command defines an argument' do
      it { expect(signature.min_argument_count).to be 1 }

      it { expect(signature.max_argument_count).to be 1 }

      it { expect(signature.allowed_keywords).to be_empty }

      it { expect(signature.required_keywords).to be_empty }
    end

    wrap_context 'when the command defines many arguments' do
      it { expect(signature.min_argument_count).to be 2 }

      it { expect(signature.max_argument_count).to be 3 }

      it { expect(signature.allowed_keywords).to be_empty }

      it { expect(signature.required_keywords).to be_empty }
    end

    wrap_context 'when the command defines a keyword' do
      it { expect(signature.min_argument_count).to be 0 }

      it { expect(signature.max_argument_count).to be 0 }

      it { expect(signature.allowed_keywords).to contain_exactly(:with_option) }

      it { expect(signature.required_keywords).to be_empty }
    end

    wrap_context 'when the command defines many keywords' do
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

    context 'when the command defines many arguments and keywords' do
      include_context 'when the command defines many arguments'
      include_context 'when the command defines many keywords'

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

  describe 'manually editing properties' do
    let(:expected) do
      properties.dup.tap do |hsh|
        hsh[:arguments][1][:required] = false

        hsh[:description] = 'Do something else.'
      end
    end

    def edit_properties
      command_class.instance_eval do
        properties[:arguments]
          .find { |hsh| hsh[:name] == :argument_two }
          .update(required: false)

        properties[:description] = 'Do something else.'
      end
    end

    wrap_context 'when the command has many properties' do
      it 'should update the properties' do
        expect { edit_properties }
          .to change(command_class, :properties)
          .to be == expected
      end
    end

    wrap_context 'with a subclass of the command' do
      wrap_context 'when the command has many properties' do
        it 'should not change the properties of the parent command' do
          expect { edit_properties }
            .not_to change(Spec::ExampleCommand, :properties)
        end

        it 'should update the properties' do
          expect { edit_properties }
            .to change(command_class, :properties)
            .to be == expected
        end
      end
    end
  end
end
