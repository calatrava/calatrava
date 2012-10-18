module Calatrava

  class IosApp
    include Rake::DSL

    def initialize(path, manifest)
      @path, @manifest = path, manifest
    end

    def build_dir ; "ios/public" ; end
    def build_html_dir ; "#{build_dir}/views" ; end
    def build_assets_dir ; "#{build_dir}/assets" ; end
    def build_scripts_dir ; "#{build_assets_dir}/scripts" ; end
    def build_images_dir ; "#{build_assets_dir}/images" ; end
    def build_styles_dir ; "#{build_assets_dir}/styles" ; end

    def coffee_files
      @manifest.coffee_files + [Calatrava::Project.current.config.path('env.coffee')]
    end

    def haml_files
      @manifest.haml_files
    end

    def install_tasks
      directory build_html_dir
      directory build_images_dir
      directory build_scripts_dir

      app_files = haml_files.collect do |hf|
        file "#{build_html_dir}/#{File.basename(hf, '.haml')}.html" => [build_html_dir, hf] do
          HamlSupport::compile_hybrid_page hf, build_html_dir, :platform => 'ios'
        end
      end

      app_files += coffee_files.collect do |cf|
        file "#{build_scripts_dir}/#{File.basename(cf, '.coffee')}.js" => [build_scripts_dir, cf] do
          coffee cf, build_scripts_dir
        end
      end

      app_files += @manifest.css_tasks(build_styles_dir)

      task :shared => [build_images_dir, build_scripts_dir] do
        cp_ne "#{ASSETS_IMG_DIR}/*", build_images_dir
        cp_ne "assets/lib/*.js", build_scripts_dir
        cp_ne "ios/res/js/*.js", build_scripts_dir
      end

      task :app => [:shared] + app_files

      desc "Builds the iOS app"
      task :build => :app do
        ENV['CMDLINE_BUILD'] = 'true'
        proj_name = Calatrava::Project.current.name
        cd 'ios' do
          sh "xcodebuild -workspace #{proj_name}.xcworkspace -scheme #{proj_name} -sdk iphonesimulator"
        end
      end

      desc "Clean ios public directory"
      task :clean do
        sh "rm -rf #{build_dir}"
      end

      namespace :xcode do
        task :prebuild do
          if !ENV['CMDLINE_BUILD']
            Rake::Task['configure:development'].invoke
            Rake::Task['ios:app'].invoke
          end
        end
      end

    end
  end

end
