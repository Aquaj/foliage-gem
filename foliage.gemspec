# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foliage/version'

Gem::Specification.new do |spec|
  spec.name          = 'foliage'
  spec.version       = Foliage::VERSION
  spec.author        = 'Jérémie Bonal'
  spec.email         = 'jbonal@ekylibre.com'
  spec.summary       = 'Leaflet.js map builder.'
  spec.description   = 'Library providings helpers and .js to more easily handle Leaflet.js maps.'
  spec.homepage      = 'http://github.com/Aquaj/foliage-gem'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z app vendor LICENSE.txt README.md lib`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_path  = 'lib'
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'rails', ['>= 3.2']
  spec.add_dependency 'jquery-rails', '~> 4.0'
  spec.add_dependency 'jquery-ui-rails'
  spec.add_dependency 'coffee-rails', '~> 4.1'
  spec.add_dependency 'sass-rails', '~> 5.0'
end
