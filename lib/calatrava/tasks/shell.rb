namespace :shell do

  directory "build/shell/css"
  directory "build/shell/js"

  desc "Convert core scss to css"
  task :scss => "build/shell/css" do
    sh "sass --update shell/stylesheets"
    cp_ne "shell/stylesheets/*.css", "build/shell/css"
  end

  desc "Build shell js files"
  task :coffee => "build/shell/js" do
    coffee "shell/pages/", "build/shell/js"
  end

end
