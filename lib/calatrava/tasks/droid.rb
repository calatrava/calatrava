namespace :droid do

  version = "1.0"

  html_views = Dir["#{SHELL_VIEWS_DIR}/*.haml"].collect do |haml|
    pageName = File.basename(haml, '.haml')
    file "#{CONFIG[:droid][:html]}/#{pageName}.html" => [haml] + FileList['shell/layouts/*.haml'] + FileList['shell/partials/**/*.haml'] do
      HamlSupport::compile haml, CONFIG[:droid][:html]
    end
  end

  desc "Creates html from haml using Android layout"
  task :haml => [CONFIG[:droid][:html]] + html_views

  desc "Compile droid-specific coffee to javascript"
  task :coffee => CONFIG[:droid][:assets] do
    coffee File.join(CONFIG[:droid][:root], "app"), CONFIG[:droid][:js]
  end

  desc "Copies required assets for droid"
  task :shared => ["shell:scss", "shell:coffee", "kernel:coffee", :haml, :coffee, CONFIG[:droid][:css], CONFIG[:droid][:imgs], CONFIG[:droid][:js], :config, CONFIG[:droid][:fonts]] do
    cp_ne "#{BUILD_CORE_CSS_DIR}/*.css", CONFIG[:droid][:css]
    cp_ne "#{ASSETS_IMG_DIR}/*", CONFIG[:droid][:imgs]
    cp_ne "#{ASSETS_LIB_DIR}/*.js", CONFIG[:droid][:js]

    CalatravaKernel.modules.each do |library|
      cp_ne "#{BUILD_CORE_KERNEL_DIR}/#{library}/*.js", CONFIG[:droid][:js]
    end

    cp_ne "#{BUILD_CORE_KERNEL_DIR}/*.js", CONFIG[:droid][:js]
    cp_ne "#{ASSETS_FONTS_DIR}/*", CONFIG[:droid][:fonts]
  end

  desc "Prepares config for the app"
  task :config do
    env_coffee = config_path("env.coffee")
    coffee env_coffee, CONFIG[:droid][:js]
  end

  desc "Builds the complete Android app"
  task :build => [:shared, :config, :write_build_number] do
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
    artifact("droid/#{Calatrava::Project.current.name}/bin/#{Calatrava::Project.current.name}.apk", ENV['CALATRAVA_ENV'])
  end

  desc "Clean droid public directory"
  task :clean do
    rm_rf CONFIG[:droid][:public]
    cd "droid/#{Calatrava::Project.current.name}" do
      sh "ant clean"
    end
  end

end
