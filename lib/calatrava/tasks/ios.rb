namespace :ios do
  html_views = Dir["#{SHELL_VIEWS_DIR}/*.haml"].collect do |haml|
    pageName = File.basename(haml, '.haml')
    file "#{CONFIG[:ios][:html]}/#{pageName}.html" => [haml] + FileList['shell/layouts/*.haml'] + FileList['shell/partials/**/*.haml'] do
      HamlSupport::compile haml, CONFIG[:ios][:html], :platform => 'ios'
    end
  end

  desc "Creates html from haml using iPhone layout"
  task :haml => [CONFIG[:ios][:html]] + html_views

  desc "Copies required assets for ios"
  task :shared => ["core:scss", "core:shell", "core:kernel", :haml, CONFIG[:ios][:css], CONFIG[:ios][:imgs], CONFIG[:ios][:js], :config, CONFIG[:ios][:fonts]] do
    sh "cp #{BUILD_CORE_CSS_DIR}/*.css #{CONFIG[:ios][:css]}"
    sh "cp #{ASSETS_IMG_DIR}/* #{CONFIG[:ios][:imgs]}"
    sh "cp #{ASSETS_LIB_DIR}/*.js #{CONFIG[:ios][:js]}"

    CalatravaKernel.modules.each do |library|
      sh "cp #{BUILD_CORE_KERNEL_DIR}/#{library}/*.js #{CONFIG[:ios][:js]}"
    end

    sh "cp #{BUILD_CORE_KERNEL_DIR}/*.js #{CONFIG[:ios][:js]}"
    sh "cp #{ASSETS_FONTS_DIR}/* #{CONFIG[:ios][:fonts]}"
  end

  desc "Prepares config for the app"
  task :config do
    env_coffee = config_path("env.coffee")
    coffee env_coffee, CONFIG[:ios][:js]
  end

  desc "Builds the iOS app"
  task :build => [:shared, :config, :write_build_number, 'ios:xcode:build:package']

  desc "Update the Settings bundle to show the correct build number"
  task :write_build_number do
    cd "ios/#{app_name}/Settings.bundle" do
      `cat Root.plist | sed -E "s/Version \\".*\\"/Version \\"#{ENV['BUILD_NUMBER']}\\"/g" > Root.plist.new`
      `mv Root.plist.new Root.plist`
    end
  end

  desc "Publish the iOS app as an artifact"
  task :publish => :build do
    artifact(CONFIG[:ios][:xcode][:package_path], ENV['CALATRAVA_ENV'])
  end

  desc "Clean ios public directory"
  task :clean do
    sh "rm -rf #{CONFIG[:ios][:public]}/*"
  end
end
