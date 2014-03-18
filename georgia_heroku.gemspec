# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'georgia_heroku/version'

Gem::Specification.new do |spec|
  spec.name          = "georgia_heroku"
  spec.version       = GeorgiaHeroku::VERSION
  spec.authors       = ["Mathieu Gagne"]
  spec.email         = ["gagne.mathieu@hotmail.com"]
  spec.summary       = %q{Prepare Georgia for Heroku}
  spec.description   = %q{Prepare Georgia CMS to be hosted on Heroku's platform}
  spec.homepage      = "https://github.com/georgia-cms/georgia_heroku"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
