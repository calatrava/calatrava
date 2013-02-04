module Calatrava

  class Project
    include Rake::DSL

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
      if platform? 'web'
        @mobile_web = MobileWebApp.new(@path, Manifest.new(@path, 'web', @kernel, @shell))
      end
      if platform? 'ios'
        @ios = IosApp.new(@path, Manifest.new(@path, 'ios', @kernel, @shell))
      end
      if platform? 'droid'
        @droid = DroidApp.new(@path, @name, Manifest.new(@path, 'droid', @kernel, @shell))
      end
    end

    def install_tasks
      namespace(:kernel)    { kernel.install_tasks }
      namespace(:configure) { config.install_tasks }

      namespace(:droid)     { droid.install_tasks }      if platform?('droid')
      namespace(:ios)       { ios.install_tasks }        if platform?('ios')
      namespace(:web)       { mobile_web.install_tasks } if platform?('web')

      desc "Clean all apps"
      task :clean => tasks_for_platforms(:clean)
      task :build => tasks_for_platforms(:build)
    end

    def platform?(p)
      @options[:platforms].include? p
    end

    def tasks_for_platforms(task)
      @options[:platforms].collect { |p| "#{p}:#{task}" }
    end

  end

end
