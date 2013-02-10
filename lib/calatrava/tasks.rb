$: << File.dirname(__FILE__)
require 'calatrava'

Calatrava::Project.here('.')

Dir["#{File.join(File.dirname(__FILE__), 'tasks')}/*.rb"].each { |t| require t }

Calatrava::Project.current.install_tasks

