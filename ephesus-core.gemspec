# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'ephesus/core/version'

Gem::Specification.new do |gem| # rubocop:disable Metrics/BlockLength
  gem.name        = 'ephesus-core'
  gem.version     = Ephesus::Core::VERSION
  gem.date        = Time.now.utc.strftime '%Y-%m-%d'
  gem.summary     = 'Core functionality for developing text-based applications.'

  description = <<-DESCRIPTION
    Core functionality for the Ephesus stack, which is a modular library for
    developing text-based interactive applications. Ephesus::Core defines common
    components which can be composed and extended by applications.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'GPL-3.0'

  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_runtime_dependency 'bronze'
  gem.add_runtime_dependency 'cuprum', '~> 0.7'
  gem.add_runtime_dependency 'hamster', '~> 3.0'
  gem.add_runtime_dependency 'patina'
  gem.add_runtime_dependency 'sleeping_king_studios-tools', '~> 0.7'
  gem.add_runtime_dependency 'zinke'

  gem.add_development_dependency 'rspec', '~> 3.8'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '2.4.0'
  gem.add_development_dependency 'rubocop', '~> 0.58', '>= 0.58.2', '< 0.59'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.21.0', '< 1.22'
  gem.add_development_dependency 'simplecov', '~> 0.16', '>= 0.16.1'
  gem.add_development_dependency 'sleeping_king_studios-tasks', '~> 0.7'
  gem.add_development_dependency 'thor', '~> 0.20'
end
