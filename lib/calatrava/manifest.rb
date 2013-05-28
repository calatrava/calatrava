module Calatrava

  class Manifest
    include Rake::DSL

    DEVICE_PREFIXES = ['ios', 'droid', 'web']

    attr_reader :src_file

    def initialize(path, app_type, kernel, shell)
      @app_type = app_type
      @path, @kernel, @shell = path, kernel, shell
      @src_file = "#{app_type}/manifest.yml"
      @feature_list = YAML.load(IO.read("#{@path}/#{@src_file}"))
    end

    def features
      @feature_list
    end

    def coffee_files
      [@shell, @kernel].collect do |src|
        src.coffee_files + feature_files(src, :coffee)
      end.flatten
    end

    def kernel_bootstrap
      @kernel.coffee_files + feature_files(@kernel, :coffee)
    end

    def haml_files
      @shell.haml_files + feature_files(@shell, :haml)
    end
    
    def css_files
      rejected_prefixes = DEVICE_PREFIXES - [@app_type]
      all_files = @shell.css_files.reject { |f| rejected_prefixes.any? { |prefix| File.basename(f).start_with? prefix } }
      device_files = all_files.select { |f| File.basename(f).start_with? @app_type }

      (all_files - device_files) + device_files # push device files to the end
    end

    def css_tasks(output_dir)
      css_files.collect do |style_file|
        file "#{output_dir}/#{File.basename(style_file, '.*')}.css" => [output_dir, style_file] do |t|
          if style_file =~ /\.css$/
            cp style_file, output_dir
          else
            sh "sass #{style_file} #{t.name}"
          end
        end
      end
    end

    def feature_files(source, type)
      source.features.select { |f| @feature_list.include?(f[:name]) }.collect { |f| f[type] }.flatten
    end
  end

end
