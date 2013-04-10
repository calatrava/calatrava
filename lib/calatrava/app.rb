require 'thor'

module Calatrava

  class App < Thor

    desc "create <project-name>", "creates a new calatrava app project"
    method_options :template => File.join(File.dirname(__FILE__), 'templates'),
                   :dev => false,
                   :'no-ios' => false,
                   :'no-droid' => false,
                   :'no-web' => false,
                   :'android-api' => '17'
    def create(project_name)
      die "template must exist" unless File.exist?(options[:template])
      die "template must be a directory" unless File.directory?(options[:template])

      proj = ProjectScript.new(project_name, options)
      proj.create(Template.new(options[:template]))
    end

    no_tasks do

      def die(message)
        $stderr.puts message
        exit 1
      end

    end

  end

end

