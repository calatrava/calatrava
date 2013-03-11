module Calatrava
  class PageGenerator
    def initialize(name)
      @name = name
    end

    def generate(template)
      create_directory_tree(template)
      create_files(template)
    end

    private
    def target_item(item)
      item.gsub("CALATRAVA_TMPL", @name)
    end

    def create_directory_tree(template)
      template.walk_directories do |dir|
        FileUtils.mkdir_p(target_item(dir))
      end
    end

    def create_files(template)
      template.walk_files do |file_info|
        target_name = target_item(file_info[:name]).gsub(".calatrava", "")

        if File.extname(file_info[:name]) == ".calatrava"
          File.open(target_name, "w+") do |f|
            expanded = Mustache.render(IO.read(file_info[:path]),
                                       :page_name => @name)
            f.print(expanded)
          end
        else
          FileUtils.cp(file_info[:path], target_name)
        end

        puts "created #{target_name}"
      end
    end
  end
end