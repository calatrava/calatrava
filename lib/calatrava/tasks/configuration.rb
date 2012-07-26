def config_for(environment)
  YAML::load(File.open(CONFIG_YAML))[environment]
end

def evaluate_template(template_path, configuration)
  file_path = File.join(CONFIG_RESULT_DIR, File.basename(template_path).gsub(".erb", ''))
  puts "Config: #{File.basename(template_path)} -> #{File.basename(file_path)}"
  result = ERB.new(IO.read(template_path)).result(binding)
  IO.write(file_path, result)
end

def config_path(file)
  env = ENV['CALATRAVA_ENV'] || "development"
  puts "CALATRAVA_ENV = '#{env}'"
  full_path = artifact_path(File.join(env, file))
  fail "Could not find '#{file}' in environment '#{env}'" unless File.exists? full_path
  full_path
end

def app_name
end

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
