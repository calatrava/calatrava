module Calatrava
  
  class DroidApp
    include Rake::DSL

    def initialize(path, proj_name, manifest)
      @path, @proj_name, @manifest = path, proj_name, manifest
      @app_builder = AppBuilder.new("droid/#{@proj_name}/assets/hybrid", @manifest)
    end

    def install_tasks
      app_task = @app_builder.builder_task

      desc "Builds the Android app"
      task :build => app_task do
        cd "droid/#{@proj_name}" do
          sh "ant clean debug"
        end
      end

      desc "Publishes the built Android app as an artifact"
      task :publish => :build do
        artifact("droid/#{@proj_name}/bin/#{@proj_name}-debug.apk", ENV['CALATRAVA_ENV'])
      end

      desc "Deploy app to device/emulator"
      task :deploy => :publish do
        sh "adb install -r artifacts/#{ENV['CALATRAVA_ENV']}/#{@proj_name}-debug.apk"
      end

      desc "Clean droid"
      task :clean do
        rm_rf @app_builder.build_dir
        cd "droid/#{@proj_name}" do
          sh "ant clean"
        end
      end
      
    end
  end

end
