module Calatrava

  class Manifest
    include Rake::DSL

    attr_reader :src_file

    def initialize(path, app_dir, kernel, shell)
      @path, @kernel, @shell = path, kernel, shell
      @src_file = "#{app_dir}/manifest.yml"
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
      @shell.css_files
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
