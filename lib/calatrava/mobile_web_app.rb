module Calatrava

  class MobileWebApp
    include Rake::DSL

    def initialize(path, manifest)
      @path, @manifest = path, manifest
      @apache = Apache.new
    end

    def build_dir
      "#{@path}/web/public"
    end

    def scripts_build_dir
      "#{build_dir}/scripts"
    end

    def coffee_files
      Dir.chdir @path do
        core_coffee = ['bridge', 'init'].collect { |l| "web/app/source/#{l}.coffee" }
        core_coffee += @manifest.coffee_files.select { |cf| cf =~ /calatrava.coffee$/ }
        web_coffee = Dir['web/app/source/*.coffee'] - core_coffee
        mf_coffee = @manifest.coffee_files.reject { |cf| cf =~ /calatrava.coffee$/ }
        core_coffee + web_coffee + [Calatrava::Project.current.config.path('env.coffee')] + mf_coffee
      end
    end

    def haml_files
      Dir.chdir(@path) { @manifest.haml_files }
    end

    def scripts
      coffee_files.collect { |cf| "scripts/#{File.basename(cf, '.coffee')}.js" }
    end

    def install_tasks
      directory build_dir
      directory scripts_build_dir

      app_files = coffee_files.collect do |cf|
        file "#{scripts_build_dir}/#{File.basename(cf, '.coffee')}.js" => [scripts_build_dir, cf] do
          coffee cf, scripts_build_dir
        end
      end

      app_files << file("#{build_dir}/index.html" => ["web/app/views/index.haml"] + haml_files) do
        HamlSupport::compile "web/app/views/index.haml", build_dir
      end

      app_files += @manifest.css_files.collect do |style_file|
        file "#{styles_build_dir}/#{File.basename(style_file, '.*')}.css" => [styles_build_dir, style_file] do |t|
          if style_file =~ /css$/
            cp style_file, styles_build_dir
          else
            sh "sass #{style_file} #{t.name}"
          end
        end
      end

      task :shared do
        cp_ne "#{ASSETS_IMG_DIR}/*", File.join(build_dir, 'images')
        cp_ne "assets/lib/*.js", scripts_build_dir
      end        

      desc "Build the web app"
      task :build => app_files + [:shared]

      desc "Publishes the built web app as an artifact"
      task :publish => :build do
        artifact_dir(build_dir, 'web/public')
      end
      
      desc "Clean web app"
      task :clean => 'apache:clean' do
        rm_rf build_dir
      end

      namespace :apache do
        @apache.install_tasks
      end

    end
  end

end
