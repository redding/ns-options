# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ns-options/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["jcredding"]
  gem.email         = ["TempestTTU@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
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
