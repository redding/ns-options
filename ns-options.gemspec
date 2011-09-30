# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ns-options/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Collin Redding"]
  gem.email         = ["collin.redding@reelfx.com"]
  gem.description   = %q{Define and use namespaced options with a clean interface.}
  gem.summary       = %q{Define and use namespaced options with a clean interface.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "ns-options"
  gem.require_paths = ["lib"]
  gem.version       = NsOptions::VERSION

  gem.add_development_dependency("assert",        ["~>0.6.0"])
  gem.add_development_dependency("assert-mocha",  ["~>0.1.0"])
end
