namespace :ios do
  html_views = Dir["#{SHELL_VIEWS_DIR}/*.haml"].collect do |haml|
    pageName = File.basename(haml, '.haml')
    file "#{CONFIG[:ios][:html]}/#{pageName}.html" => [haml] + FileList['shell/layouts/*.haml'] + FileList['shell/partials/**/*.haml'] do
      HamlSupport::compile haml, CONFIG[:ios][:html], :platform => 'ios'
    end
  end

  desc "Creates html from haml using iPhone layout"
  task :haml => [CONFIG[:ios][:html]] + html_views

  directory 'ios/public/assets'

  desc "Copies required assets for ios"
  task :shared => ["shell:scss", "shell:coffee", "kernel:coffee", 'ios/public/assets',
                    CONFIG[:ios][:css], CONFIG[:ios][:imgs], CONFIG[:ios][:js], :config, CONFIG[:ios][:fonts]] do
    cp_ne "#{BUILD_CORE_CSS_DIR}/*.css", CONFIG[:ios][:css]
    cp_ne "#{ASSETS_IMG_DIR}/*", CONFIG[:ios][:imgs]
    cp_ne "assets/lib/*.js", CONFIG[:ios][:js]
    cp_ne "ios/res/js/*.js", CONFIG[:ios][:js]

    ios_manifest = Calatrava::Manifest.new('ios')
    ios_manifest.js_files.each do |js_file|
      sh "cp #{js_file} #{CONFIG[:ios][:js]}"
    end
    ios_manifest.load_file('ios/public/assets', '%@/public/assets/scripts', :type => :text, :include_pages => false)

    cp_ne "#{BUILD_CORE_KERNEL_DIR}/*.js", CONFIG[:ios][:js]
    cp_ne "#{ASSETS_FONTS_DIR}/*", CONFIG[:ios][:fonts]
  end

  task :app => [:shared, :haml]

  desc "Prepares config for the app"
  task :config do
    env_coffee = config_path("env.coffee")
    coffee env_coffee, CONFIG[:ios][:js]
  end

  task :configured_app => [:app, :config]

  desc "Builds the iOS app"
  task :build => :configured_app do
    ENV['CMDLINE_BUILD'] = 'true'
    Calatrava::Project.current.build_ios
  end

  desc "Publish the iOS app as an artifact"
  task :publish => :build do
    artifact(CONFIG[:ios][:xcode][:package_path], ENV['CALATRAVA_ENV'])
  end

  desc "Clean ios public directory"
  task :clean do
    sh "rm -rf #{CONFIG[:ios][:public]}/*"
  end

  namespace :xcode do
    task :prebuild do
      if !ENV['CMDLINE_BUILD']
        Rake::Task['configure:development'].invoke
        Rake::Task['ios:configured_app'].invoke
      end
    end
  end
end
