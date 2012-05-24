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
  env = ENV['CALATRAVA_ENV']
  fail "Don't know which environment to build for. Have you set CALATRAVA_ENV?" unless env
  full_path = artifact_path(File.join(env, file))
  fail "Could not find '#{file}' in environment '#{env}'" unless File.exists? full_path
  full_path
end

def app_name
end
