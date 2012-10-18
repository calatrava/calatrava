module Calatrava

  class Project

    def self.here(directory)
      @@current = Project.new(directory)
    end

    def self.current
      @@current
    end

    attr_reader :name, :config, :kernel, :mobile_web, :ios

    def initialize(name, overrides = {})
      @name = name
      @slug = name.gsub(" ", "_").downcase
      @title = @name[0..0].upcase + @name[1..-1]
      @options = {}
      if File.exists?(@name) && File.directory?(@name)
        @path = File.expand_path(@name)
        @options = YAML.load(IO.read(File.join(@name, 'calatrava.yml')))
        @name = @options[:project_name]
      end
      @options.merge! overrides

      @config = Calatrava::Configuration.new
      @kernel = Calatrava::Kernel.new(@path)
      @shell = Calatrava::Shell.new(@path)
      @mobile_web = Calatrava::MobileWebApp.new(@path, Calatrava::Manifest.new(@path, 'web', @kernel, @shell))
      @ios = Calatrava::IosApp.new(@path, Calatrava::Manifest.new(@path, 'ios', @kernel, @shell))
    end

  end

end
