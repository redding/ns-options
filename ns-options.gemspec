# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ns-options/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Collin Redding", "Kelly Redding"]
  gem.email         = ["collin.redding@me.com", "kelly@kellyredding.com"]
  gem.description   = %q{A DSL for defining, organizing and accessing options.}
  gem.summary       = %q{A DSL for defining, organizing and accessing options.}
  gem.homepage      = "https://github.com/redding/ns-options"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "ns-options"
  gem.require_paths = ["lib"]
  gem.version       = NsOptions::VERSION

  gem.add_development_dependency("assert", ["~>1.0"])
end
