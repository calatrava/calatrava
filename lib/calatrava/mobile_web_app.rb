module Calatrava

  class MobileWebApp
    include Rake::DSL

    def initialize(path, manifest)
      @path, @manifest = path, manifest
      @apache = Apache.new
    end

    def build_dir ; "#{@path}/web/public" ; end
    def scripts_build_dir ; "#{build_dir}/scripts" ; end
    def styles_build_dir ; "#{build_dir}/styles" ; end
    def images_build_dir ; "#{build_dir}/images" ; end

    def coffee_files
      Dir.chdir @path do
        core_coffee = ['bridge', 'init'].collect { |l| "web/app/source/#{l}.coffee" }
        core_coffee += @manifest.coffee_files.select { |cf| cf =~ /calatrava.coffee$/ }
        web_coffee = Dir['web/app/source/*.coffee'] - core_coffee
        mf_coffee = @manifest.coffee_files.reject { |cf| cf =~ /calatrava.coffee$/ }
        env_file = OutputFile.new(scripts_build_dir, Calatrava::Project.current.config.path('env.coffee'), ['configure:calatrava_env'])
        (core_coffee + web_coffee + mf_coffee).collect { |cf| OutputFile.new(scripts_build_dir, cf) } + [env_file]
      end
    end

    def haml_files
      Dir.chdir(@path) { @manifest.haml_files }
    end

    def scripts
      coffee_files.collect do |cf|
        cf.output_path.gsub("#{build_dir}/", "")
      end
    end

    def install_tasks
      directory build_dir
      directory scripts_build_dir
      directory styles_build_dir
      directory images_build_dir

      app_files = coffee_files.collect { |cf| cf.to_task }

      app_files << file("#{build_dir}/index.html" => [@manifest.src_file,
                                                      "web/app/views/index.haml",
                                                      transient('web_coffee', coffee_files),
                                                      transient('web_haml', haml_files)] + haml_files) do
        HamlSupport::compile "web/app/views/index.haml", build_dir
      end

      app_files += @manifest.css_tasks(styles_build_dir)

      task :shared => [images_build_dir, scripts_build_dir] do
        cp_ne "assets/images/*", File.join(build_dir, 'images')
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
