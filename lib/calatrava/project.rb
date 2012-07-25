require 'mustache'
require 'yaml'
require 'xcoder'
require 'xcodeproj'

module Calatrava

  class Project

    def self.here(directory)
      @@current = Project.new(directory)
    end

    def self.current
      @@current
    end

    attr_reader :name

    def initialize(name, overrides = {})
      @name = name
      @options = {}
      if File.exists?(@name) && File.directory?(@name)
        @path = File.expand_path(@name)
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

      create_android_tree(template)
      create_ios_tree(template)
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

    def create_android_tree(template)
      Dir.chdir(File.join(@name, "droid")) do
        system("android create project --name #{@name} --path #{@name} --package com.#{@name} --target android-10 --activity Launcher")

        Dir.walk("calatrava") do |item|
          FileUtils.mkdir_p(item) if File.directory? item
          FileUtils.cp(item, item) if File.file? item
        end

        FileUtils.rm_rf "calatrava"
      end
    end

    def create_ios_tree(template)
      require 'pry'
      proj = Xcodeproj::Project.new

      # walk thru dir tree
      # -create group for dir
      # -add each file to group

      current_group = proj.main_group

      base_dir = Pathname.new(@name) + "ios"
      walker = lambda do |item|
        #binding.pry
        if item.directory?
          group_name = item.basename
          current_group = current_group.create_group group_name
          item.each_child &walker
        elsif item.file?
          current_group.create_file item.relative_path_from(base_dir).to_s
        else
          raise 'what is it then?!'
        end
      end
      (base_dir + "src").each_child &walker

      proj.save_as (base_dir + "#{@name}.xcodeproj").to_s
    end

    def modules
      Dir[File.join(@path, 'kernel/app/*')].select { |n| File.directory? n }.collect { |n| File.basename n }
    end

    def src_paths
      modules.collect { |m| "app/#{m}" }.join(':')
    end


    def build_ios(options = {})
      proj = Xcode.project("ios/App/App.xcodeproj")
      builder = proj.target(options[:target]).config(options[:config]).builder
      builder.clean
      builder.sdk = options[:sdk] || :iphonesimulator
      builder.build
      builder.package
    end

  end

end
