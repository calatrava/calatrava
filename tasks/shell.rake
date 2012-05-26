namespace :shell do

  directory "build/shell" => "build"
  directory "build/shell/css" => "build/shell"
  directory "build/shell/js" => "build/shell"

  desc "Convert core scss to css"
  task :scss => "build/shell/css" do
    sh "sass --update shell/stylesheets"
    sh "cp shell/stylesheets/*.css build/shell/css"
  end

  desc "Build shell js files"
  task :shell => "build/shell/js" do
    coffee "shell/app", "build/shell/js"
  end

end
