module Calatrava

  class Template

    def initialize(directory)
      @directory = directory
    end

    def target_name(item)
      item.sub("#{@directory}/", "")
    end

    def walk_tree(start_dir, &blk)
      Dir["#{start_dir}/{*,.*}"].each do |item|
        blk.call item
        if File.directory?(item) && !(item =~ /\/\.$/) && !(item =~ /\/\.\.$/)
          walk_tree(item, &blk)
        end
      end
    end

    def walk_directories(&blk)
      walk_tree(@directory) do |item|
        if File.directory?(item)
          blk.call target_name(item)
        end
      end
    end

    def walk_files(&blk)
      walk_tree(@directory) do |item|
        if File.file? item
          blk.call(:path => item, :name => target_name(item))
        end
      end
    end

  end

end
