namespace :artifact do
  
  desc "Removes all pre-existing artifacts"
  task :clean do
    rm_rf "artifacts/*.*"
  end

end
