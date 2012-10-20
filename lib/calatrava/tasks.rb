$: << File.dirname(__FILE__)
require 'calatrava'

Calatrava::Project.here('.')

Dir["#{File.join(File.dirname(__FILE__), 'tasks')}/*.rb"].each { |t| require t }

namespace(:kernel)    { Calatrava::Project.current.kernel.install_tasks }
namespace(:configure) { Calatrava::Project.current.config.install_tasks }
namespace(:droid)     { Calatrava::Project.current.droid.install_tasks }
namespace(:ios)       { Calatrava::Project.current.ios.install_tasks }
namespace(:web)       { Calatrava::Project.current.mobile_web.install_tasks }

desc "Clean all apps"
task :clean => ['web:clean', 'ios:clean', 'droid:clean']

task :build => ['web:build', 'ios:build', 'droid:build']
