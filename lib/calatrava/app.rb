require 'thor'

module Calatrava

  class App < Thor
    map "g" => :generate

    desc "create <project-name>", "creates a new calatrava app project"
    method_options :template => File.join(File.dirname(__FILE__), 'templates'),
                   :dev => false,
                   :'no-ios' => false,
                   :'no-droid' => false,
                   :'no-web' => false
    def create(project_name)
      die "template must exist" unless File.exist?(options[:template])
      die "template must be a directory" unless File.directory?(options[:template])

      proj = ProjectScript.new(project_name, options)
      proj.create(Template.new(options[:template]))
    end

    desc "generate <controller|page> <name>", "generates placeholder files for controllers or pages"
    method_options :template => File.join(File.dirname(__FILE__), 'generators/templates'),
                   :namespace => 'example'
    def generate(type, name)
      die "type must be controller or page" unless %w(controller page).include? type

      gen = case type
        when 'controller' then ControllerGenerator.new(options[:namespace], name)
        when 'page' then PageGenerator.new(name)
      end
      gen.generate(Template.new(File.join(options[:template], type)))
    end

    no_tasks do

      def die(message)
        $stderr.puts message
        exit 1
      end

    end

  end

end

