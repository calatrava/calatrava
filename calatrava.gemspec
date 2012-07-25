# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "calatrava/version"

Gem::Specification.new do |s|
  s.name        = "calatrava"
  s.version     = Calatrava::Version
  s.authors     = ["Giles Alexander"]
  s.email       = ["gga@thoughtworks.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

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
  s.add_runtime_dependency "xcoder"
  s.add_runtime_dependency "xcodeproj"
  s.add_runtime_dependency "cucumber"
  s.add_runtime_dependency "frank-cucumber"
  s.add_runtime_dependency "watir-webdriver"
end
