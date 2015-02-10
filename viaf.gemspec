# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'viaf/version'

Gem::Specification.new do |spec|
  spec.name          = "viaf"
  spec.version       = Viaf::VERSION
  spec.authors       = ["Josh Steverman"]
  spec.email         = ["jstever@umich.edu"]
  spec.summary       = %q{Extraction of VIAF corporate names. Comparison with Govdocs. Associated scripts.}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
