require 'aruba/api'
require 'open-uri'

class CalatravaApp

  include Aruba::Api

  def initialize(name)
    @name = name
    run_simple("calatrava create #{@name} --no-droid --no-ios")
  end

  def start_apache
    cd @name
    run_simple 'rake web:apache:background'

    not_running_yet = true
    while not_running_yet
      begin
        open('http://localhost:8888') { |_| not_running_yet = false }
      rescue Errno::ECONNREFUSED
        # still not running
      end
    end

    Kernel.at_exit do
      run_simple 'rake web:apache:stop'
    end
  end

end
