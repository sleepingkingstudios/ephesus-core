# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/core/commands/signature'

RSpec.describe Ephesus::Core::Commands::Signature do
  shared_context 'when the command has one optional argument' do
    before(:example) do
      command_class.instance_eval do
        argument :optional_arg, required: false
      end
    end
  end

  shared_context 'when the command has one required argument' do
    before(:example) do
      command_class.instance_eval do
        argument :required_arg, required: true
      end
    end
  end

  shared_context 'when the command has mixed optional and required arguments' do
    before(:example) do
      command_class.instance_eval do
        argument :first_arg,  required: true
        argument :second_arg, required: true
        argument :third_arg,  required: true
        argument :fourth_arg, required: false
        argument :fifth_arg,  required: false
        argument :sixth_arg,  required: false
      end
    end
  end

  shared_context 'when the command has one optional keyword' do
    before(:example) do
      command_class.instance_eval do
        keyword :optional_key, required: false
      end
    end
  end

  shared_context 'when the command has one required keyword' do
    before(:example) do
      command_class.instance_eval do
        keyword :required_key, required: true
      end
    end
  end

  shared_context 'when the command has mixed optional and required keywords' do
    before(:example) do
      command_class.instance_eval do
        keyword :first_required_key,  required: true
        keyword :second_required_key, required: true
        keyword :third_required_key,  required: true
        keyword :first_optional_key,  required: false
        keyword :second_optional_key, required: false
        keyword :third_optional_key,  required: false
      end
    end
  end

  shared_context 'when the command has mixed arguments and keywords' do
    before(:example) do
      command_class.instance_eval do
        argument :first_arg,  required: true
        argument :second_arg, required: true
        argument :third_arg,  required: false
        keyword  :first_key,  required: false
        keyword  :second_key, required: true
        keyword  :third_key,  required: false
      end
    end
  end

  subject(:instance) { described_class.new(command_class) }

  let(:command_class) { Spec::ExampleCommand }

  example_class 'Spec::ExampleCommand', base_class: Ephesus::Core::Command

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#command_class' do
    include_examples 'should have reader', :command_class, -> { command_class }
  end

  describe '#allowed_keywords' do
    include_examples 'should have reader', :allowed_keywords, []

    wrap_context 'when the command has one optional keyword' do
      it 'should return the allowed keywords' do
        expect(instance.allowed_keywords).to contain_exactly(:optional_key)
      end
    end

    wrap_context 'when the command has one required keyword' do
      it 'should return the allowed keywords' do
        expect(instance.allowed_keywords).to contain_exactly(:required_key)
      end
    end

    wrap_context 'when the command has mixed optional and required keywords' do
      let(:expected) do
        %i[
          first_optional_key
          second_optional_key
          third_optional_key
          first_required_key
          second_required_key
          third_required_key
        ]
      end

      it 'should return the allowed keywords' do
        expect(instance.allowed_keywords).to contain_exactly(*expected)
      end
    end

    wrap_context 'when the command has mixed arguments and keywords' do
      let(:expected) do
        %i[
          first_key
          second_key
          third_key
        ]
      end

      it 'should return the allowed keywords' do
        expect(instance.allowed_keywords).to contain_exactly(*expected)
      end
    end
  end

  describe '#match' do
    shared_examples 'should return an error result' do
      it { expect(success).to be false }

      it { expect(error_result).to be_a Ephesus::Core::Commands::Result }

      it { expect(error_result.errors).to include default_error }
    end

    let(:arguments) { [] }
    let(:keywords)  { {} }
    let(:success) do
      instance
        .match(*arguments, **keywords)
        .yield_self { |bool, _| bool }
    end
    let(:error_result) do
      instance
        .match(*arguments, **keywords)
        .yield_self { |_, result| result }
    end
    let(:default_error) { :invalid_arguments }

    it 'should define the method' do
      expect(instance)
        .to respond_to(:match)
        .with_unlimited_arguments
        .and_any_keywords
    end

    context 'when the command has no arguments or keywords' do
      # rubocop:disable RSpec/NestedGroups
      describe 'with no arguments or keywords' do
        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end
      # rubocop:enable RSpec/NestedGroups

      # rubocop:disable RSpec/NestedGroups
      describe 'with too many arguments' do
        let(:arguments) { %w[ichi ni san] }
        let(:expected_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 0,
              actual:   3
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end
      # rubocop:enable RSpec/NestedGroups

      # rubocop:disable RSpec/NestedGroups
      describe 'with invalid keywords' do
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:expected_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: [],
              actual:   %i[yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end
      # rubocop:enable RSpec/NestedGroups
    end

    wrap_context 'when the command has one optional argument' do
      describe 'with no arguments or keywords' do
        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with one argument' do
        let(:arguments) { %w[ichi] }

        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with too many arguments' do
        let(:arguments) { %w[ichi ni san] }
        let(:expected_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 1,
              actual:   3
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with invalid keywords' do
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:expected_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: [],
              actual:   %i[yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end
    end

    wrap_context 'when the command has one required argument' do
      describe 'with no arguments or keywords' do
        let(:expected_error) do
          {
            type:   :not_enough_arguments,
            params: {
              expected: 1,
              actual:   0
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with one argument' do
        let(:arguments) { %w[ichi] }

        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with too many arguments' do
        let(:arguments) { %w[ichi ni san] }
        let(:expected_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 1,
              actual:   3
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with invalid keywords' do
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:expected_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: [],
              actual:   %i[yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end
    end

    wrap_context 'when the command has mixed optional and required arguments' do
      describe 'with no arguments or keywords' do
        let(:expected_error) do
          {
            type:   :not_enough_arguments,
            params: {
              expected: 3,
              actual:   0
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with one argument' do
        let(:arguments) { %w[ichi] }
        let(:expected_error) do
          {
            type:   :not_enough_arguments,
            params: {
              expected: 3,
              actual:   1
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with three arguments' do
        let(:arguments) { %w[ichi ni san] }

        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with six arguments' do
        let(:arguments) { %w[ichi ni san yon go roku] }

        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with too many arguments' do
        let(:arguments) { %w[ichi ni san yon go roku nana hachi kyuu] }
        let(:expected_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 6,
              actual:   9
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with invalid keywords' do
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:arguments_error) do
          {
            type:   :not_enough_arguments,
            params: {
              expected: 3,
              actual:   0
            }
          }
        end
        let(:keywords_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: [],
              actual:   %i[yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should include an argument count error' do
          expect(error_result.errors[:arguments]).to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include keywords_error }
      end

      describe 'with three arguments and invalid keywords' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:arguments_error) do
          {
            type:   :not_enough_arguments,
            params: {
              expected: 3,
              actual:   0
            }
          }
        end
        let(:keywords_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: [],
              actual:   %i[yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should not include an argument count error' do
          expect(error_result.errors[:arguments]).not_to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include keywords_error }
      end
    end

    wrap_context 'when the command has one optional keyword' do
      describe 'with no arguments or keywords' do
        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with too many arguments' do
        let(:arguments) { %w[ichi ni san] }
        let(:expected_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 0,
              actual:   3
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with invalid keywords' do
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:expected_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[optional_key],
              actual:   %i[yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with valid and invalid keywords' do
        let(:keywords) { { optional_key: 'value', yon: 4, go: 5, roku: 6 } }
        let(:expected_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[optional_key],
              actual:   %i[optional_key yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end
    end

    wrap_context 'when the command has one required keyword' do
      describe 'with no arguments or keywords' do
        let(:expected_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[required_key],
              actual:   %i[],
              missing:  %i[required_key]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with too many arguments' do
        let(:arguments) { %w[ichi ni san] }
        let(:arguments_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 0,
              actual:   3
            }
          }
        end
        let(:keywords_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[required_key],
              actual:   %i[],
              missing:  %i[required_key]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should include an argument count error' do
          expect(error_result.errors[:arguments]).to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include keywords_error }
      end

      describe 'with valid keywords' do
        let(:keywords) { { required_key: 'value' } }

        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with invalid keywords' do
        let(:keywords) { { required_key: 'value', yon: 4, go: 5, roku: 6 } }
        let(:expected_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[required_key],
              actual:   %i[required_key yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with missing keywords' do
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:expected_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[required_key],
              actual:   %i[yon go roku],
              missing:  %i[required_key]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with missing and invalid keywords' do
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:invalid_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[required_key],
              actual:   %i[yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end
        let(:missing_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[required_key],
              actual:   %i[yon go roku],
              missing:  %i[required_key]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include invalid_error }

        it { expect(error_result.errors[:arguments]).to include missing_error }
      end

      describe 'with too many arguments and missing and invalid keywords' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords) { { yon: 4, go: 5, roku: 6 } }
        let(:arguments_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 0,
              actual:   3
            }
          }
        end
        let(:invalid_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[required_key],
              actual:   %i[yon go roku],
              invalid:  %i[yon go roku]
            }
          }
        end
        let(:missing_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[required_key],
              actual:   %i[yon go roku],
              missing:  %i[required_key]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should include an argument count error' do
          expect(error_result.errors[:arguments]).to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include invalid_error }

        it { expect(error_result.errors[:arguments]).to include missing_error }
      end
    end

    wrap_context 'when the command has mixed optional and required keywords' do
      describe 'with no arguments or keywords' do
        let(:expected_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[
                first_required_key
                second_required_key
                third_required_key
              ],
              actual:   %i[],
              missing:  %i[
                first_required_key
                second_required_key
                third_required_key
              ]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with too many arguments' do
        let(:arguments) { %w[ichi ni san] }
        let(:arguments_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 0,
              actual:   3
            }
          }
        end
        let(:keywords_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[
                first_required_key
                second_required_key
                third_required_key
              ],
              actual:   %i[],
              missing:  %i[
                first_required_key
                second_required_key
                third_required_key
              ]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should include an argument count error' do
          expect(error_result.errors[:arguments]).to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include keywords_error }
      end

      describe 'with valid keywords' do
        let(:keywords) do
          {
            first_required_key:  'value',
            second_required_key: 'value',
            third_required_key:  'value',
            first_optional_key:  'value'
          }
        end

        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with invalid keywords' do
        let(:keywords) do
          {
            first_required_key:  'value',
            second_required_key: 'value',
            third_required_key:  'value',
            first_optional_key:  'value',
            yon:                 4,
            go:                  5,
            roku:                6
          }
        end
        let(:expected_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[
                first_required_key
                second_required_key
                third_required_key
                first_optional_key
                second_optional_key
                third_optional_key
              ],
              actual:   %i[
                first_required_key
                second_required_key
                third_required_key
                first_optional_key
                yon
                go
                roku
              ],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with missing keywords' do
        let(:keywords) do
          {
            first_optional_key:  'value',
            second_optional_key: 'value',
            first_required_key:  'value'
          }
        end
        let(:expected_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[
                first_required_key
                second_required_key
                third_required_key
              ],
              actual:   %i[
                first_optional_key
                second_optional_key
                first_required_key
              ],
              missing:  %i[
                second_required_key
                third_required_key
              ]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with missing and invalid keywords' do
        let(:keywords) do
          {
            first_required_key:  'value',
            second_required_key: 'value',
            first_optional_key:  'value',
            second_optional_key: 'value',
            yon:                 4,
            go:                  5,
            roku:                6
          }
        end
        let(:invalid_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[
                first_required_key
                second_required_key
                third_required_key
                first_optional_key
                second_optional_key
                third_optional_key
              ],
              actual:   %i[
                first_required_key
                second_required_key
                first_optional_key
                second_optional_key
                yon
                go
                roku
              ],
              invalid:  %i[yon go roku]
            }
          }
        end
        let(:missing_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[
                first_required_key
                second_required_key
                third_required_key
              ],
              actual:   %i[
                first_required_key
                second_required_key
                first_optional_key
                second_optional_key
                yon
                go
                roku
              ],
              missing:  %i[third_required_key]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include invalid_error }

        it { expect(error_result.errors[:arguments]).to include missing_error }
      end

      describe 'with too many arguments and missing and invalid keywords' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords) do
          {
            first_required_key:  'value',
            second_required_key: 'value',
            first_optional_key:  'value',
            second_optional_key: 'value',
            yon:                 4,
            go:                  5,
            roku:                6
          }
        end
        let(:arguments_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 0,
              actual:   3
            }
          }
        end
        let(:invalid_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[
                first_required_key
                second_required_key
                third_required_key
                first_optional_key
                second_optional_key
                third_optional_key
              ],
              actual:   %i[
                first_required_key
                second_required_key
                first_optional_key
                second_optional_key
                yon
                go
                roku
              ],
              invalid:  %i[yon go roku]
            }
          }
        end
        let(:missing_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[
                first_required_key
                second_required_key
                third_required_key
              ],
              actual:   %i[
                first_required_key
                second_required_key
                first_optional_key
                second_optional_key
                yon
                go
                roku
              ],
              missing:  %i[third_required_key]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should include an argument count error' do
          expect(error_result.errors[:arguments]).to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include invalid_error }

        it { expect(error_result.errors[:arguments]).to include missing_error }
      end
    end

    wrap_context 'when the command has mixed arguments and keywords' do
      describe 'with no arguments or keywords' do
        let(:arguments_error) do
          {
            type:   :not_enough_arguments,
            params: {
              expected: 2,
              actual:   0
            }
          }
        end
        let(:keywords_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[second_key],
              actual:   %i[],
              missing:  %i[second_key]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should include an argument count error' do
          expect(error_result.errors[:arguments]).to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include keywords_error }
      end

      describe 'with one argument' do
        let(:arguments) { %w[ichi] }
        let(:arguments_error) do
          {
            type:   :not_enough_arguments,
            params: {
              expected: 2,
              actual:   1
            }
          }
        end
        let(:keywords_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[second_key],
              actual:   %i[],
              missing:  %i[second_key]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should include an argument count error' do
          expect(error_result.errors[:arguments]).to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include keywords_error }
      end

      describe 'with one argument and valid keywords' do
        let(:arguments) { %w[ichi] }
        let(:keywords)  { { second_key: 'value' } }
        let(:expected_error) do
          {
            type:   :not_enough_arguments,
            params: {
              expected: 2,
              actual:   1
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with three arguments' do
        let(:arguments) { %w[ichi ni san] }
        let(:expected_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[second_key],
              actual:   %i[],
              missing:  %i[second_key]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with three arguments and valid keywords' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords)  { { second_key: 'value' } }

        it { expect(success).to be true }

        it { expect(error_result).to be nil }
      end

      describe 'with too many arguments' do
        let(:arguments) { %i[ichi ni san yon go roku] }
        let(:arguments_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 3,
              actual:   6
            }
          }
        end
        let(:keywords_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[second_key],
              actual:   %i[],
              missing:  %i[second_key]
            }
          }
        end

        include_examples 'should return an error result'

        it 'should include an argument count error' do
          expect(error_result.errors[:arguments]).to include arguments_error
        end

        it { expect(error_result.errors[:arguments]).to include keywords_error }
      end

      describe 'with too many arguments and valid keywords' do
        let(:arguments) { %i[ichi ni san yon go roku] }
        let(:expected_error) do
          {
            type:   :too_many_arguments,
            params: {
              expected: 3,
              actual:   6
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with invalid keywords' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords) do
          {
            first_key:  'value',
            second_key: 'value',
            third_key:  'value',
            yon:        4,
            go:         5,
            roku:       6
          }
        end
        let(:expected_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[
                first_key
                second_key
                third_key
              ],
              actual:   %i[
                first_key
                second_key
                third_key
                yon
                go
                roku
              ],
              invalid:  %i[yon go roku]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with missing keywords' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords)  { { first_key: 'value' } }
        let(:expected_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[second_key],
              actual:   %i[first_key],
              missing:  %i[second_key]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include expected_error }
      end

      describe 'with missing and invalid keywords' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords) do
          {
            first_key:  'value',
            yon:        4,
            go:         5,
            roku:       6
          }
        end
        let(:invalid_error) do
          {
            type:   :invalid_keywords,
            params: {
              expected: %i[
                first_key
                second_key
                third_key
              ],
              actual:   %i[
                first_key
                yon
                go
                roku
              ],
              invalid:  %i[yon go roku]
            }
          }
        end
        let(:missing_error) do
          {
            type:   :missing_keywords,
            params: {
              expected: %i[second_key],
              actual:   %i[
                first_key
                yon
                go
                roku
              ],
              missing:  %i[second_key]
            }
          }
        end

        include_examples 'should return an error result'

        it { expect(error_result.errors[:arguments]).to include invalid_error }

        it { expect(error_result.errors[:arguments]).to include missing_error }
      end
    end
  end

  describe '#max_argument_count' do
    include_examples 'should have reader', :max_argument_count, 0

    wrap_context 'when the command has one optional argument' do
      it { expect(instance.max_argument_count).to be 1 }
    end

    wrap_context 'when the command has one required argument' do
      it { expect(instance.max_argument_count).to be 1 }
    end

    wrap_context 'when the command has mixed optional and required arguments' do
      it { expect(instance.max_argument_count).to be 6 }
    end

    wrap_context 'when the command has mixed arguments and keywords' do
      it { expect(instance.max_argument_count).to be 3 }
    end
  end

  describe '#min_argument_count' do
    include_examples 'should have reader', :min_argument_count, 0

    wrap_context 'when the command has one optional argument' do
      it { expect(instance.min_argument_count).to be 0 }
    end

    wrap_context 'when the command has one required argument' do
      it { expect(instance.min_argument_count).to be 1 }
    end

    wrap_context 'when the command has mixed optional and required arguments' do
      it { expect(instance.min_argument_count).to be 3 }
    end

    wrap_context 'when the command has mixed arguments and keywords' do
      it { expect(instance.min_argument_count).to be 2 }
    end
  end

  describe '#optional_keywords' do
    include_examples 'should have reader', :optional_keywords, []

    wrap_context 'when the command has one optional keyword' do
      it 'should return the optional keywords' do
        expect(instance.optional_keywords).to contain_exactly(:optional_key)
      end
    end

    wrap_context 'when the command has one required keyword' do
      it { expect(instance.optional_keywords).to be_empty }
    end

    wrap_context 'when the command has mixed optional and required keywords' do
      let(:expected) do
        %i[
          first_optional_key
          second_optional_key
          third_optional_key
        ]
      end

      it 'should return the optional keywords' do
        expect(instance.optional_keywords).to contain_exactly(*expected)
      end
    end

    wrap_context 'when the command has mixed arguments and keywords' do
      it 'should return the optional keywords' do
        expect(instance.optional_keywords)
          .to contain_exactly(:first_key, :third_key)
      end
    end
  end

  describe '#required_keywords' do
    include_examples 'should have reader', :required_keywords, []

    wrap_context 'when the command has one optional keyword' do
      it { expect(instance.required_keywords).to be_empty }
    end

    wrap_context 'when the command has one required keyword' do
      it 'should return the required keywords' do
        expect(instance.required_keywords).to contain_exactly(:required_key)
      end
    end

    wrap_context 'when the command has mixed optional and required keywords' do
      let(:expected) do
        %i[
          first_required_key
          second_required_key
          third_required_key
        ]
      end

      it 'should return the required keywords' do
        expect(instance.required_keywords).to contain_exactly(*expected)
      end
    end

    wrap_context 'when the command has mixed arguments and keywords' do
      it 'should return the required keywords' do
        expect(instance.required_keywords).to contain_exactly(:second_key)
      end
    end
  end
end
