ROOT_DIR ||= ".".freeze
FEATURES_DIR = File.join('.', 'features').freeze
FEATURE_RESULTS_DIR = File.join('.', 'results').freeze

namespace :automation do
  namespace :web do
    desc "Runs cucumber tests against the web app"
    task :features, [:file] => [:clean_up_results_dir] do |t, args|
      ENV['PATH'] = "#{ROOT_DIR}/web/features:#{ENV['PATH']}"
      features_to_be_run = args[:file] ? "#{FEATURES_DIR}/#{args[:file]}" : FEATURES_DIR
      sh "cucumber --strict --tags @all,@web --tags ~@wip #{features_to_be_run} --format html --out #{FEATURE_RESULTS_DIR}/report.html --format pretty"
    end

    desc "delete and create the results dir"
    task :clean_up_results_dir do
      sh "rm -rf #{FEATURE_RESULTS_DIR}"
      sh "mkdir #{FEATURE_RESULTS_DIR}"
    end
  end

end
