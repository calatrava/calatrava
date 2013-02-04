require 'aruba/cucumber'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

ENV['RUBYLIB'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../lib')}#{File::PATH_SEPARATOR}#{ENV['RUBYLIB']}"

Before do
  @aruba_timeout_seconds = 40
end

class CalatravaWorld

  def create_app(name)
    @app = CalatravaApp.new(name)
  end

  def current_app
    @app
  end

end

World { CalatravaWorld.new }
