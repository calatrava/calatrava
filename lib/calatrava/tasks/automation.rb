namespace :automation do
  namespace :web do
    desc "Runs cucumber tests against the web app"
    task :features, [:file] => [:apache_for_features, :create_sim_link, :copy_steps_file, :clean_up_results_dir] do |t, args|
      ENV['PATH'] = "#{ROOT_DIR}/web/features:#{ENV['PATH']}"
      features_to_be_run = args[:file] ? "#{FEATURES_DIR}/#{args[:file]}" : FEATURES_DIR
      sh "cucumber --strict --tags @all,@web --tags ~@wip #{features_to_be_run} --format html --out #{FEATURE_RESULTS_DIR}/report.html --format pretty"
    end

    desc "launch a daemon apache instance on port 8888 which will serve the features and mock the backend services"
    task :apache_for_features => ['web:build', APACHE_LOGS_DIR] do
      create_plist
      configure_apache
      `launchctl unload #{APACHE_DIR}/com.jenkins.calatrava.apache.plist`
      `launchctl load -w #{APACHE_DIR}/com.jenkins.calatrava.apache.plist`
      `sleep 5`
    end

    desc "create sim link for the ios step_definitions and support folder"
    task :create_sim_link do
      sh "rm -rf #{FEATURES_DIR}/step_definitions"
      sh "rm -rf  #{FEATURES_DIR}/support"
    end

    desc "copy the web_steps file to web_steps.rb"
    task :copy_steps_file do
      sh "rm -f #{FEATURES_DIR}/*.rb"
      sh "cp  #{FEATURES_DIR}/web_steps #{FEATURES_DIR}/web_steps.rb"
    end

    desc "delete and create the results dir"
    task :clean_up_results_dir do
      sh "rm -rf #{FEATURE_RESULTS_DIR}"
      sh "mkdir #{FEATURE_RESULTS_DIR}"
    end
  end

end
