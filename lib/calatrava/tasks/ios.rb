namespace :ios do

  ios_manifest = Calatrava::Manifest.new('ios')

  html_views = ios_manifest.features.collect do |feature|
    html_dir = "ios/public/views"
    Dir["shell/pages/#{feature}/*.haml"].collect do |page|
      pageName = File.basename(page, '.haml')
      file "#{html_dir}/#{pageName}.html" => page do
        HamlSupport::compile_hybrid_page feature, page, html_dir, :platform => 'ios'
      end
    end
  end.flatten

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

    ios_manifest.js_files.each do |js_file|
      sh "cp #{js_file} #{CONFIG[:ios][:js]}"
    end
    ios_manifest.load_file('ios/public/assets', '%@/public/assets/scripts', :type => :text, :include_pages => false)

    cp_ne "build/shell/js/**/*.js", CONFIG[:ios][:js]
    cp_ne "build/kernel/js/*.js", CONFIG[:ios][:js]
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
    proj_name = Calatrava::Project.current.name
    cd 'ios' do
      sh "xcodebuild -workspace #{proj_name}.xcworkspace -scheme #{proj_name} -sdk iphonesimulator"
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

  namespace :xcode do
    task :prebuild do
      if !ENV['CMDLINE_BUILD']
        Rake::Task['configure:development'].invoke
        Rake::Task['ios:configured_app'].invoke
      end
    end
  end
end
