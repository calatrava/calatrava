module Calatrava

  class Project

    def self.here(directory)
      @@current = Project.new(directory)
    end

    def self.current
      @@current
    end

    attr_reader :name, :config, :kernel, :mobile_web, :ios, :droid

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

      @config = Configuration.new
      @kernel = Kernel.new(@path)
      @shell = Shell.new(@path)
      @mobile_web = MobileWebApp.new(@path, Manifest.new(@path, 'web', @kernel, @shell))
      @ios = IosApp.new(@path, Manifest.new(@path, 'ios', @kernel, @shell))
      @droid = DroidApp.new(@path, @name, Manifest.new(@path, 'droid', @kernel, @shell))
    end

  end

end
