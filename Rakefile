require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

namespace :test do
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = "--color"
  end

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
  end
end

desc "Run all tests"
task :test => ['test:rspec', 'test:features']

desc "Create a test project"
task :run do
  sh "bin/calatrava create test --dev"
end