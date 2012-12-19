module Calatrava

  class Shell
    def initialize(proj_path)
      @path = proj_path
    end

    def js_files
      Dir.chdir @path do
        Dir["shell/support/*.js"] + Dir["shell/support/*.js"]
      end
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
          Dir["shell/stylesheets/*.#{ext}"]
        end.flatten
      end
    end

    def features
      Dir.chdir @path do
        Dir["shell/pages/*"].collect do |f|
          if File.directory?(f)
            {
              :name => File.basename(f),
              :js => Dir["#{f}/*.js"],
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
