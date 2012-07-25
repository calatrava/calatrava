module Calatrava

  class Manifest
    def initialize(app_dir)
      @feature_list = YAML.load(IO.read("#{app_dir}/manifest.yml"))
    end

    def js_files
      @feature_list.collect { |f| Dir.glob("build/kernel/js/#{f}/*.js") }.flatten
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

    def coffee_files(feature, opts)
      coffee_files = Dir["kernel/app/#{feature}/*.coffee"]
      if !opts[:include_pages]
        coffee_files = coffee_files.reject { |f| f =~ /page\./ }
      end
      coffee_files
    end

    def haml(js_src)
      %{%script(type="text/javascript" src="#{js_src}")}
    end

    def text(js_src)
      js_src
    end
  end

end
