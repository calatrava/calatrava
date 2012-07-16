require 'haml'

module HamlSupport

  class Helper

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
      partial_template = IO.read(File.join(ENV['VIEWS_DIR'], 'partials', "#{partial_name}.haml"))
      Haml::Engine.new(partial_template).render(self, locals)
    end

    def render_shell_partial(partial_name, locals = {})
      partial_template = IO.read(File.join(SHELL_PARTIALS_DIR, "#{partial_name}.haml"))
      Haml::Engine.new(partial_template).render(self, locals)
    end

  end

  class << self

    def compile(haml_path, html_dir, options = {})
      html_file = File.basename(haml_path, '.*') + '.html'
      html_path = File.join(html_dir, html_file)
      template = IO.read(haml_path)
      haml_helper = Helper.new

      puts "haml: #{haml_path} -> #{html_path}"

      html = Haml::Engine.new(template).render(haml_helper)

      html.gsub!("file:///android_asset/hybrid", "../assets") if options[:platform] == 'ios'

      IO.write(html_path, html)
    end
  end

end
