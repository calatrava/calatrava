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
  task :shared => ["core:scss", "core:shell", "core:kernel", :haml, :coffee, CONFIG[:droid][:css], CONFIG[:droid][:imgs], CONFIG[:droid][:js], :config, CONFIG[:droid][:fonts]] do
    sh "cp #{BUILD_CORE_CSS_DIR}/*.css #{CONFIG[:droid][:css]}"
    sh "cp #{ASSETS_IMG_DIR}/* #{CONFIG[:droid][:imgs]}"
    sh "cp #{ASSETS_LIB_DIR}/*.js #{CONFIG[:droid][:js]}"

    CalatravaKernel.modules.each do |library|
      sh "cp #{BUILD_CORE_KERNEL_DIR}/#{library}/*.js #{CONFIG[:droid][:js]}"
    end

    sh "cp #{BUILD_CORE_KERNEL_DIR}/*.js #{CONFIG[:droid][:js]}"
    sh "cp #{ASSETS_FONTS_DIR}/* #{CONFIG[:droid][:fonts]}"
  end

  desc "Prepares config for the app"
  task :config do
    env_coffee = config_path("env.coffee")
    coffee env_coffee, CONFIG[:droid][:js]
  end

  desc "Builds the complete Android app"
  task :build => [:shared, :config, :write_build_number] do
    cd "droid/#{app_name}" do
      sh "ant clean debug"
    end
  end

  desc "Update the app to show the correct build number"
  task :write_build_number do
    cd "droid/#{app_name}" do
      `cat AndroidManifest.xml | sed -E "s/android:versionName=\".*\"/android:versionName=\\"#{ENV['BUILD_NUMBER']}\\"/g" > AndroidManifest.xml.new`
      `mv AndroidManifest.xml.new AndroidManifest.xml`
    end
  end

  desc "Publishes the built Android app as an artifact"
  task :publish => :build do
    artifact("droid/#{app_name}/bin/#{app_name}.apk", ENV['CALATRAVA_ENV'])
  end

  desc "Clean droid public directory"
  task :clean do
    rm_rf CONFIG[:droid][:public]
    cd "droid/#{app_name}" do
      sh "ant clean"
    end
  end

end
