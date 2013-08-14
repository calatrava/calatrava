module Calatrava

  class Shell
    def initialize(proj_path)
      @path = proj_path
    end

    def coffee_files
      Dir.chdir @path do
        Dir["shell/support/*.coffee"] + Dir["shell/support/*.coffee"]
      end
    end

    def haml_files
      Dir.chdir @path do
        Dir["shell/support/*.haml"]
      end
    end

    def css_files
      Dir.chdir @path do
        ["sass", "scss", "css"].collect do |ext|
          Dir["shell/stylesheets/**/[^_]*.#{ext}"]
        end.flatten
      end
    end

    def features
      Dir.chdir @path do
        Dir["shell/pages/*"].collect do |f|
          if File.directory?(f)
            {
              :name => File.basename(f),
              :coffee => Dir["#{f}/*.coffee"],
              :haml => Dir["#{f}/*.haml"]
            }
          else
            nil
          end
        end.compact
      end
    end
  end

end
