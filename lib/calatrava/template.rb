class Dir

  def self.walk(start_dir, &blk)
    Dir["#{start_dir}/{*,.*}"].each do |item|
      blk.call item
      if File.directory?(item) && !(item =~ /\/\.$/) && !(item =~ /\/\.\.$/)
        walk(item, &blk)
      end
    end
  end

end

module Calatrava

  class Template

    def initialize(directory)
      @directory = directory
    end

    def target_name(item)
      item.sub("#{@directory}/", "")
    end

    def walk_directories(&blk)
      Dir.walk(@directory) do |item|
        if File.directory?(item)
          blk.call target_name(item)
        end
      end
    end

    def walk_files(&blk)
      Dir.walk(@directory) do |item|
        if File.file? item
          blk.call(:path => item, :name => target_name(item))
        end
      end
    end

  end

end
