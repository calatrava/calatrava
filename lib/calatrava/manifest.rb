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

    def load_file(target_dir, js_load_path, options)
      File.open("#{target_dir}/load_file.#{options[:type]}", "w+") do |f|
        @feature_list.each do |feature|
          coffee_files(feature, :include_pages => options[:include_pages]).each do |coffee_file|
            js_src = File.join(js_load_path, File.basename(coffee_file, '.coffee') + ".js")
            f.puts self.send(options[:type], js_src)
          end
        end
      end
    end

    def js_files
      [@kernel, @shell].collect do |src|
        src.js_files + feature_files(src, :js)
      end.flatten
    end

    def coffee_files
      [@shell, @kernel].collect do |src|
        src.coffee_files + feature_files(src, :coffee)
      end.flatten
    end

    def kernel_bootstrap
      @kernel.coffee_files + feature_files(@kernel, :coffee)
    end

    def kernel_bootstrap_js
      (@kernel.js_files + feature_files(@kernel, :js)).uniq
    end

    def haml_files
      @shell.haml_files + feature_files(@shell, :haml)
    end
    
    def css_files
      @shell.css_files
    end

    def css_tasks(output_dir)
      mkdir_p output_dir
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

    def haml(js_src)
      %{%script(type="text/javascript" src="#{js_src}")}
    end

    def text(js_src)
      js_src
    end
  end

end
