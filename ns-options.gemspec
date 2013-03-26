# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ns-options/version"

Gem::Specification.new do |gem|
  gem.name          = "ns-options"
  gem.version       = NsOptions::VERSION
  gem.authors       = ["Collin Redding", "Kelly Redding"]
  gem.email         = ["collin.redding@me.com", "kelly@kellyredding.com"]
  gem.description   = %q{A DSL for defining, organizing and accessing options.}
  gem.summary       = %q{A DSL for defining, organizing and accessing options.}
  gem.homepage      = "https://github.com/redding/ns-options"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert",  ["~> 2.0"])

end
