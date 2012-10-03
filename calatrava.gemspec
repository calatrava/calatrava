# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "calatrava/version"

Gem::Specification.new do |s|
  s.name        = "calatrava"
  s.version     = Calatrava::Version
  s.authors     = ["Giles Alexander"]
  s.email       = ["giles.alexander@gmail.com"]
  s.homepage    = "http://calatrava.github.com"
  s.summary     = %q{Cross-platform mobile apps with native UIs}
  s.description = %q{A framework to build cross-platform mobile apps with high quality native UIs.}

  s.rubyforge_project = "calatrava"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "aruba"

  s.add_runtime_dependency "rake"
  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "sass"
  s.add_runtime_dependency "mustache"
  s.add_runtime_dependency "cucumber"
  s.add_runtime_dependency "watir-webdriver"
  s.add_runtime_dependency "frank-cucumber"
  s.add_runtime_dependency "xcodeproj"
  s.add_runtime_dependency "cocoapods"
end
