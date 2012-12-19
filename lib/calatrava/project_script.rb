require 'mustache'
require 'yaml'
require 'xcodeproj' if RUBY_PLATFORM =~ /darwin/

module Calatrava

  class ProjectScript

    attr_reader :name

    def initialize(name, overrides = {})
      @name = name
      @slug = name.gsub(" ", "_").downcase
      @title = @name[0..0].upcase + @name[1..-1]
      @options = overrides
    end

    def sh(cmd)
      $stdout.puts cmd
      system(cmd)
    end

    def dev?
      @options[:is_dev]
    end

    def create(template)
      create_project(template)
      create_directory_tree(template)
      create_files(template)

      create_android_tree(template)
      create_ios_tree(template) if RUBY_PLATFORM =~ /darwin/
    end

    def create_project(template)
      FileUtils.mkdir_p @name
      File.open(File.join(@name, 'calatrava.yml'), "w+") do |f|
        f.print({:project_name => @name}.to_yaml)
      end
    end

    def target_item(item)
      item.gsub("CALATRAVA_TMPL", @name)
    end

    def create_directory_tree(template)
      template.walk_directories do |dir|
        FileUtils.mkdir_p(File.join(@name, target_item(dir)))
      end
    end

    def create_files(template)
      template.walk_files do |file_info|
        target_name = target_item(file_info[:name])
        if File.extname(file_info[:name]) == ".calatrava"
          File.open(File.join(@name, target_name.gsub(".calatrava", "")), "w+") do |f|
            expanded = Mustache.render(IO.read(file_info[:path]),
                                       :project_name => @name,
                                       :project_slug => @slug,
                                       :project_title => @title,
                                       :dev? => dev?)
            f.print(expanded)
          end
        else
          FileUtils.cp(file_info[:path], File.join(@name, target_name))
        end
      end
    end

    def create_android_tree(template)
      Dir.chdir(File.join(@name, "droid")) do
        sh "android create project --name '#{@slug}' --path '#{@name}' --package com.#{@slug} --target android-10 --activity #{@title}"

        Dir.walk("calatrava") do |item|
          target_item = item.sub('calatrava', @name)
          FileUtils.mkdir_p(target_item) if File.directory? item
          FileUtils.cp(item, target_item) if File.file? item
        end
        Dir.chdir "#{@name}" do
          Dir.chdir "#{@name}" do
            FileUtils.mv "build.xml", "../build.xml"
            FileUtils.mv "AndroidManifest.xml", "../AndroidManifest.xml"
          end
          FileUtils.rm_rf "#{@name}"
          Dir.chdir "src/com/#{@name}" do
            FileUtils.mv "Title.java", "#{@title}.java"
          end
        end

        FileUtils.rm_rf "calatrava"
      end
    end

    def create_ios_project
      Xcodeproj::Project.new
    end

    def create_ios_project_groups(base_dir, proj, target)
      source_files_for_target = []

      walker = lambda do |item, group|
        if item.directory?
          group_name = item.basename
          child_group = group.new_group(group_name.to_s)
          item.each_child { |item| walker.call(item, child_group) }
        elsif item.file?
          file_path = item.relative_path_from(base_dir)
          source_files_for_target << group.new_file(file_path.to_s)
        else
          raise 'what is it then?!'
        end
      end
      (base_dir + "src").each_child { |item| walker.call(item, proj.main_group) }
      target.add_file_references source_files_for_target
    end

    def create_ios_folder_references(base_dir, proj, target)
      public_folder = proj.main_group.new_file "public"
      public_folder.last_known_file_type = 'folder'

      shared_phase = Xcodeproj::Project::Object::PBXResourcesBuildPhase.new(proj, nil)
      shared_phase.add_file_reference(public_folder)
      target.build_phases << shared_phase

    end

    def create_ios_project_target(proj)
      proj.new_target(:application, @name, :ios).tap do |target|

        target.build_configurations.each do |config|
          config.build_settings.merge!({
                                         "GCC_PREFIX_HEADER" => "src/#{@name}-Prefix.pch",
                                         "OTHER_LDFLAGS" => ['-ObjC', '-all_load'],
                                         "INFOPLIST_FILE" => "src/#{@name}-Info.plist",
                                         "SKIP_INSTALL" => "NO",
                                         "IPHONEOS_DEPLOYMENT_TARGET" => "5.0",
                                       })
          config.build_settings.delete "DSTROOT"
          config.build_settings.delete "INSTALL_PATH"

        end

        %w{UIKit CoreGraphics}.each do |name|
          fw = proj.frameworks_group.new_file("System/Library/Frameworks/#{name}.framework")
          fw.name = "#{name}.framework"
          fw.source_tree = 'SDKROOT'

          bf = proj.new(Xcodeproj::Project::Object::PBXBuildFile)
          bf.file_ref = fw
          target.frameworks_build_phase.files << bf
        end


        calatrava_phase = proj.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)

        # hacky manual way to get build phase inserted in the right place
        target.build_phases.insert(0, calatrava_phase) 
        calatrava_phase.add_referrer(target.build_phases.owner)

        calatrava_phase.name = "Build Calatrava Kernel & Shell"
        calatrava_phase.shell_path = '/bin/bash'
        calatrava_phase.shell_script = <<-EOS.split("\n").collect(&:strip).join("\n")
          source ${SRCROOT}/../build_env.sh
          bundle exec rake ios:xcode:prebuild
        EOS
      end
    end

    def create_ios_tree(template)
      proj = create_ios_project
      base_dir = Pathname.new(@name) + "ios"

      target = create_ios_project_target(proj)
      create_ios_project_groups(base_dir, proj, target)
      create_ios_folder_references(base_dir, proj, target)

      proj.save_as (base_dir + "#{@name}.xcodeproj").to_s
    end
  end

end
