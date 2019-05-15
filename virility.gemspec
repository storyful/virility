# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'virility/version'

Gem::Specification.new do |gem|
  # Details
  gem.name          = 'virility'
  gem.version       = Virility::VERSION
  gem.authors       = ['Jay Sanders']
  gem.email         = ['jay@allieslabs.com']
  gem.description   = "Virility leverages the API's of many popular social services to collect data about the virility of a particular URL."
  gem.summary       = "Virility calls upon the API's of many popular social services such as Facebook, Reddit and Pinterest to collect the number of likes, tweets and pins of a particular URL.  Written with a modular construction, Virility makes it easy to drop new data collection strategies into the framework so that you can collect all of your statistics in one easy location."
  gem.homepage      = 'http://github.com/mindtonic/virility'
  gem.licenses      = %w[MIT Beerware]
  # Files
  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  # Development
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'guard-rubocop'
  gem.add_development_dependency 'pry', '~> 0.12'
  gem.add_development_dependency 'rspec', '~> 3.8'
  gem.add_development_dependency 'rubocop', '~> 0.69.0'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.33'
  gem.add_development_dependency 'rubocop-performance', '~> 1.3'
  # Dependencies
  gem.add_dependency 'httparty', '~> 0.11'
  gem.add_dependency 'koala', '~> 3.0.0'
  gem.add_dependency 'multi_json', '~> 1.11'
end
