require 'erb'

module Calatrava

  class Configuration
    include Rake::DSL

    @@extras = []
    def self.extra(&configurator)
      @@extras << configurator
    end

    def initialize
      @runtime = {}
    end

    def config_result_dir
      "config/result"
    end
    def config_yaml
      "config/environments.yml"
    end
    def config_template_dir
      "config/templates"
    end
    def templates
      Rake::FileList["#{config_template_dir}/*.erb"]
    end

    def config_for(environment)
      @@extras.each { |e| e.call(self) }
      @runtime.merge(YAML::load(File.open(config_yaml))[environment])
    end

    def runtime(key, value)
      @runtime[key] = value
    end

    def evaluate_template(template_path, configuration)
      file_path = File.join(config_result_dir, File.basename(template_path).gsub(".erb", ''))
      puts "Config: #{File.basename(template_path)} -> #{File.basename(file_path)}"
      result = ERB.new(IO.read(template_path)).result(binding)
      IO.write(file_path, result)
    end

    def path(file)
      env = ENV['CALATRAVA_ENV'] || "development"
      puts "CALATRAVA_ENV = '#{env}'"
      full_path = artifact_path(File.join(env, file))
      full_path
    end

    def install_tasks
      directory config_result_dir

      %w{local development test automation production}.each do |environment|
        desc "Create config files for #{environment} environment"
        task environment.to_sym => [:clean, config_result_dir] do
          configuration = config_for(environment)
          templates.each do |template|
            evaluate_template(template, configuration)
          end
          artifact_dir(config_result_dir, environment)
        end
      end

      task :clean do
        rm_rf config_result_dir
      end
    end
  end

end
