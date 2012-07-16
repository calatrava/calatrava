require 'mustache'
require 'yaml'

module Calatrava

  class Project

    attr_reader :name

    def initialize(name, overrides = {})
      @name = name
      @options = {}
      if File.exists?(@name) && File.directory?(@name)
        @options = YAML.load(IO.read(File.join(@name, 'calatrava.yml')))
        @name = @options[:project_name]
      end
      @options.merge! overrides
    end

    def dev?
      @options[:is_dev]
    end

    def create(template)
      create_project(template)
      create_directory_tree(template)
      create_files(template)
    end

    def create_project(template)
      FileUtils.mkdir_p @name
      File.open(File.join(@name, 'calatrava.yml'), "w+") do |f|
        f.print({:project_name => @name}.to_yaml)
      end
    end

    def create_directory_tree(template)
      template.walk_directories do |dir|
        FileUtils.mkdir_p(File.join(@name, dir))
      end
    end

    def create_files(template)
      template.walk_files do |file_info|
        if File.extname(file_info[:name]) == ".calatrava"
          File.open(File.join(@name, file_info[:name].gsub(".calatrava", "")), "w+") do |f|
            f.print(Mustache.render(IO.read(file_info[:path]), :project_name => @name, :dev? => dev?))
          end
        else
          FileUtils.cp(file_info[:path], File.join(@name, file_info[:name]))
        end
      end
    end

  end

end
