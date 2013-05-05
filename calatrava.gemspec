# -*- encoding: utf-8; mode: ruby -*-
$:.push File.expand_path("../lib", __FILE__)
require "calatrava/version"
require "calatrava/platform"

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

  s.add_runtime_dependency "rake", ">= 0.9.5"
  
  s.add_runtime_dependency "thor", "~> 0.16.0"
  s.add_runtime_dependency "haml", "~> 3.1.7"
  s.add_runtime_dependency "sass", "~> 3.2.3"
  s.add_runtime_dependency "mustache", "~> 0.99.4"
  s.add_runtime_dependency "cucumber", "~> 1.2.1"
  s.add_runtime_dependency "watir-webdriver", "~> 0.6.1"

  if Calatrava.platform == :mac
    s.add_runtime_dependency "xcodeproj", ">= 0.4.0" 
    s.add_runtime_dependency "cocoapods", "~> 0.16.0"
  end
end
