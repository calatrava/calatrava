namespace :release do

  promoted_path = 'promoted_dir'

  directory promoted_path

  desc "Acquires the promoted artifacts to be released"
  task :files => promoted_path do
    artifacts_url = "http://localhost:8080/job/#{ENV['PROMOTED_JOB_NAME']}/#{ENV['PROMOTED_NUMBER']}/artifact/artifacts/#{ENV['CALATRAVA_ENV']}"

    cd promoted_path do
      sh "curl -O '#{artifacts_url}/#{app_name}.ipa'"
      sh "curl -O '#{artifacts_url}/#{app_name}.apk'"
    end
  end

end
