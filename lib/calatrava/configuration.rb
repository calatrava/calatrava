require 'erb'

module Calatrava

  class Configuration
    include Rake::DSL

    @@extras = []
    @@env = ENV['CALATRAVA_ENV'] || 'development'

    def self.extra(&configurator)
      @@extras << configurator
    end

    def self.env
      @@env
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
      @runtime.merge(environments_yml[environment])
    end

    def environment_names
      environments_yml.keys
    end

    def environments_yml
      @environments_yml ||= YAML::load(File.open(config_yaml))
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
      artifact_path(File.join(Configuration.env, file))
    end

    def install_tasks
      directory config_result_dir

      puts "CALATRAVA_ENV = '#{Configuration.env}'"
      transient :calatrava_env, Configuration.env

      environment_names.each do |environment|
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
