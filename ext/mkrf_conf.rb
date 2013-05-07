# This is a hack to enable platform-specific dependencies in a single gem.
# For background info see:
# http://www.programmersparadox.com/2012/05/21/gemspec-loading-dependent-gems-based-on-the-users-system/

# Code primarily borrowed from here:
# https://github.com/mmzyk/gem_dependency_example

require "rubygems/dependency_installer.rb"

installer = Gem::DependencyInstaller.new
begin

  # I don't *think* you can use Calatrava.platform == :mac here as it seems
  # RubyGems builds Ruby extensions without the dependencies declared in the gemspec.
  if RUBY_PLATFORM =~ /darwin/
    installer.install "xcodeproj", ">= 0.4.0"
    installer.install "cocoapods", "~> 0.16.0"
  end

rescue Exception => ex
  # Exit with a non-zero value to let RubyGems know something went wrong.
  exit 1
end

# Since this is Ruby, RubyGems will attempt to run Rake.
# If it doesn't find and successfully run a Rakefile, it errors out.
File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w") do |f|
  f.write "task :default\n"
end
