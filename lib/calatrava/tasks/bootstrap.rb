desc "Installs all required Ruby gems and Node.js packages for your new Calatrava project."
task :bootstrap do
  sh "bundle install"
  sh "npm install"
  cd "ios" do
    sh "pod install"
  end

  Rake::Task['configure:development'].invoke
end
