module Calatrava

  class IosApp
    include Rake::DSL

    def initialize(path, manifest)
      @path, @manifest = path, manifest
      @app_builder = AppBuilder.new('ios', 'ios/public', @manifest)
    end

    def install_tasks
      app_task = @app_builder.builder_task

      desc "Builds the iOS app"
      task :build => app_task do
        ENV['CMDLINE_BUILD'] = 'true'
        proj_name = Calatrava::Project.current.name
        cd 'ios' do
          sh "xcodebuild -workspace #{proj_name}.xcworkspace -scheme #{proj_name} -sdk iphonesimulator"
        end
      end

      desc "Bootstraps the iOS app"
      task :bootstrap do
        cd "ios" do
          sh "pod install" if Calatrava.platform == :mac
        end
      end

      desc "Clean ios public directory"
      task :clean do
        sh "rm -rf #{@app_builder.build_dir}"
      end

      namespace :xcode do
        task :prebuild do
          if !ENV['CMDLINE_BUILD']
            Rake::Task['configure:development'].invoke
            app_task.invoke
          end
        end
      end

    end
  end

end
