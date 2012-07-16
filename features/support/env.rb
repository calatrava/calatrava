require 'aruba/cucumber'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

ENV['RUBYLIB'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../lib')}#{File::PATH_SEPARATOR}#{ENV['RUBYLIB']}"
