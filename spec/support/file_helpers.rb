# frozen_string_literal: true

module Spec::Support
  module FileHelpers
    class << self
      def file_path_for_example_group(example_group)
        example_group
          .class
          .ancestors
          .select { |ancestor| ancestor < RSpec::Core::ExampleGroup }
          .map(&:description)
          .map { |description| normalize_description(description) }
          .reverse
          .yield_self { |ary| File.join ary }
      end

      def root_path
        __dir__.sub('spec/support', '')
      end

      def temp_dir_path
        File.join(root_path, 'tmp', 'ci', 'rspec')
      end

      def temp_file_path(file_path)
        File.join temp_dir_path, file_path
      end

      def write_temp_file(file_path, contents)
        expanded_path = temp_file_path(file_path)
        directory     = File.dirname(expanded_path)

        FileUtils.mkdir_p directory unless File.directory?(directory)

        File.write(expanded_path, contents)
      end

      private

      def normalize_description(description)
        tools
          .string
          .underscore(description)
          .gsub(/\s+|::/, '_')
          .gsub(/[^\w]/, '')
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end
  end
end
