require 'haml'

module HamlSupport

  class Helper
    
    attr_reader :page_name

    def initialize(page_path = nil)
      @page_path = page_path
      @page_name = File.basename(@page_path, '.haml') if @page_path
    end

    def content_for(named_chunk)
      chunk = @chunks[named_chunk]
      (chunk && chunk.call) || ""
    end

    def layout_with(layout_name, content_blocks = {})
      @chunks = content_blocks
      layout_template = IO.read(File.join(SHELL_LAYOUTS_DIR, "#{layout_name}.haml"))
      Haml::Engine.new(layout_template).render(self, {})
    end

    def render_partial(partial_name, locals = {})
      partial_name = "#{partial_name}.haml" unless partial_name =~ /haml$/
      partial_template = IO.read partial_name
      Haml::Engine.new(partial_template).render(self, locals)
    end

    def render_page(locals = {})
      page_template = IO.read(@page_path)
      Haml::Engine.new(page_template).render(self, locals)
    end

  end

  class << self

    def compile_hybrid_page(page_path, output_path, options = {})
      puts "haml page: #{page_path} -> #{output_path}"

      options[:helper] = Helper.new(page_path)
      options[:template] = "shell/layouts/single_page.haml"
      options[:out] = File.join(output_path, File.basename(page_path, '.*') + '.html')

      render_haml(options)
    end

    def compile(haml_path, html_dir, options = {})
      puts "haml: #{haml_path} -> #{html_dir}"

      options[:helper] ||= Helper.new
      options[:template] = haml_path
      options[:out] = File.join(html_dir, File.basename(haml_path, '.*') + '.html')

      render_haml(options)
    end

    def render_haml(options)
      html_path = options[:out]
      template = IO.read(options[:template])

      html = Haml::Engine.new(template).render(options[:helper])

      IO.write(html_path, html)
    end
  end

end
