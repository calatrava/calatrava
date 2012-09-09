namespace :droid do

  version = "1.0"
  droid_manifest = Calatrava::Manifest.new('droid')

  html_views = droid_manifest.features.collect do |feature|
    html_dir = "droid/#{Calatrava::Project.current.name}/assets/hybrid/views"
    Dir["shell/pages/#{feature}/*.haml"].collect do |page|
      pageName = File.basename(page, '.haml')
      file "#{html_dir}/#{pageName}.html" => page do
        HamlSupport::compile_hybrid_page feature, page, html_dir
      end
    end
  end.flatten

  desc "Creates html from haml using Android layout"
  task :haml => [CONFIG[:droid][:html]] + html_views

  desc "Compile droid-specific coffee to javascript"
  task :coffee => CONFIG[:droid][:assets] do
    coffee File.join(CONFIG[:droid][:root], "app"), CONFIG[:droid][:js]
  end

  desc "Copies required assets for droid"
  task :shared => ["shell:scss", "shell:coffee", "kernel:coffee",
                    CONFIG[:droid][:css], CONFIG[:droid][:imgs], CONFIG[:droid][:js],
                    :config, CONFIG[:droid][:fonts]] do
    cp_ne "#{BUILD_CORE_CSS_DIR}/*.css", CONFIG[:droid][:css]
    cp_ne "#{ASSETS_IMG_DIR}/*", CONFIG[:droid][:imgs]
    cp_ne "assets/lib/*.js", CONFIG[:droid][:js]

    droid_manifest.js_files.each do |js_file|
      sh "cp #{js_file} #{CONFIG[:droid][:js]}"
    end
    droid_manifest.load_file("droid/#{Calatrava::Project.current.name}/assets/hybrid", 'hybrid/scripts', :type => :text, :include_pages => false)

    cp_ne "build/shell/js/**/*.js", CONFIG[:droid][:js]
    cp_ne "build/kernel/js/*.js", CONFIG[:droid][:js]
    cp_ne "#{ASSETS_FONTS_DIR}/*", CONFIG[:droid][:fonts]
  end

  task :app => [:shared, :haml, :coffee]

  desc "Prepares config for the app"
  task :config do
    env_coffee = config_path("env.coffee")
    coffee env_coffee, CONFIG[:droid][:js]
  end

  desc "Builds the complete Android app"
  task :build => [:app, :config, :write_build_number] do
    cd "droid/#{Calatrava::Project.current.name}" do
      sh "ant clean debug"
    end
  end

  desc "Update the app to show the correct build number"
  task :write_build_number do
    cd "droid/#{Calatrava::Project.current.name}" do
      sh %{cat AndroidManifest.xml | sed -E "s/android:versionName=\".*\"/android:versionName=\\"#{version}\\">/g" > AndroidManifest.xml.new}
      mv "AndroidManifest.xml.new", "AndroidManifest.xml"
    end
  end

  desc "Publishes the built Android app as an artifact"
  task :publish => :build do
    artifact("droid/#{Calatrava::Project.current.name}/bin/#{Calatrava::Project.current.name}-debug.apk", ENV['CALATRAVA_ENV'])
  end

  desc "Deploy app to device/emulator"
  task :deploy => :publish do
    sh "adb install -r artifacts/#{ENV['CALATRAVA_ENV']}/#{Calatrava::Project.current.name}-debug.apk"
  end

  desc "Clean droid public directory"
  task :clean do
    rm_rf CONFIG[:droid][:public]
    cd "droid/#{Calatrava::Project.current.name}" do
      sh "ant clean"
    end
  end

end
