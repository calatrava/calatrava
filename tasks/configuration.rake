TEMPLATES = FileList["#{CONFIG_TEMPLATE_DIR}/*.erb"]

namespace :configure do

  %w{local development test automation production}.each do |environment|
    desc "Create config files for #{environment} environment"
    task environment.to_sym => [:clean, CONFIG_RESULT_DIR] do
      configuration = config_for(environment)
      TEMPLATES.each do |template|
        evaluate_template(template, configuration)
      end
      artifact_dir(CONFIG_RESULT_DIR, environment)
    end
  end

  task :clean do
    rm_rf CONFIG_RESULT_DIR
  end
end
