namespace :web do

  desc "Creates html from haml using web layout"
  task :haml => CONFIG[:web][:public] do
    HamlSupport::compile "#{CONFIG[:web][:layout]}/index.haml", CONFIG[:web][:public]
  end

  desc "Compile web-specific coffee to javascript"
  task :coffee => CONFIG[:web][:assets] do
    coffee File.join(CONFIG[:web][:root], "app", "source"), CONFIG[:web][:js]
  end

  task :shared => ["shell:scss", "shell:coffee", "kernel:coffee",
                  CONFIG[:web][:css], CONFIG[:web][:imgs], CONFIG[:web][:js], CONFIG[:web][:fonts]] do
    cp_ne "build/shell/css/*.css", CONFIG[:web][:css]
    cp_ne "#{ASSETS_IMG_DIR}/*", CONFIG[:web][:imgs]
    cp_ne "assets/lib/*.js", CONFIG[:web][:js]

    web_manifest = Calatrava::Manifest.new('web')

    web_manifest.js_files.each do |js_file|
      sh "cp #{js_file} #{CONFIG[:web][:js]}"
    end

    web_manifest.load_file('web/app/views', 'scripts', :type => :haml, :include_pages => true)

    cp_ne "build/shell/js/**/*.js", CONFIG[:web][:js]
    cp_ne "build/kernel/js/*.js", CONFIG[:web][:js]
    cp_ne "#{ASSETS_FONTS_DIR}/*", CONFIG[:web][:fonts]
  end

  task :app => [:shared, :haml, :coffee]

  desc "Prepares config for the app"
  task :config do
    env_coffee = config_path("env.coffee")
    coffee env_coffee, CONFIG[:web][:js]
  end

  desc "Build the web app"
  task :build => [:app, :config]

  desc "Publishes the built web app as an artifact"
  task :publish => :build do
    artifact_dir(CONFIG[:web][:public], 'web/public')
    artifact config_path("mw.conf"), 'web'
    artifact 'web/deploy_mw.sh', 'web'
  end

  namespace :apache do

    file 'web/apache/public' do
      cd 'web/apache' do
        ln_s "../public", "public"
      end
    end

    desc "launch a non-daemon apache instance on port 8888 which will serve our local app and also proxy to backend services"
    task :start => [:build, 'web/apache/public', APACHE_LOGS_DIR] do
      configure_apache
      launch_apache
    end

    desc "Reload the apache configuration"
    task :reload do
      reload_apache
    end

    desc "Stop the apache configuration"
    task :stop do
      stop_apache
    end
  end

  desc "Clean web public directory"
  task :clean do
    rm_rf CONFIG[:web][:public]
    rm_rf APACHE_LOGS_DIR
    rm_rf File.join(APACHE_DIR, 'conf', 'httpd.conf')
  end

end
