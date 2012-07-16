namespace :precommit do
  old_env = ''

  task :dev_env do
    ENV['CALATRAVA_ENV'] = 'development' unless ENV['CALATRAVA_ENV']
  end

  task :begin_automation do
    old_env = ENV['CALATRAVA_ENV']
    ENV['CALATRAVA_ENV'] = 'automation'
  end

  task :end_automation do
    ENV['CALATRAVA_ENV'] = old_env
  end

  task :web_features => [:begin_automation, "configure:automation", "automation:acl:start", "automation:web:features", "automation:acl:stop", :end_automation]

  desc "Run this before pushing"
  task :mw => [:dev_env, "kernel:spec", "kernel:features", :web_features]

end
