require 'pathname'

module Calatrava
  
  class OutputFile
    @@rules = {}

    def self.rule(opts, &action)
      start_ext = opts.keys[0]
      @@rules[start_ext] = {:target => opts[start_ext], :action => action}
    end

    def self.target_file(file_name)
      start_ext = file_name.extname
      Pathname.new(file_name.basename(start_ext).to_s + rule_for(start_ext)[:target])
    end

    def self.action(file_name)
      rule_for(file_name.extname)[:action]
    end

    def self.rule_for(ext)
      @@rules[ext]
    end

    include Rake::DSL
    attr_reader :source_file, :dependencies

    def initialize(output_dir, source_file, dependencies = [])
      @output_dir = Pathname.new(output_dir)
      @source_file = Pathname.new(source_file)

      @dependencies = [@source_file.to_s, @output_dir.to_s]
      @dependencies += dependencies if dependencies
    end

    def output_path
      (@output_dir + OutputFile.target_file(@source_file)).to_s
    end
    alias :to_s :output_path

    def to_task
      task do
        OutputFile.action(@source_file).call(output_path.to_s, @source_file.to_s)
      end
    end
  end

  OutputFile.rule '.coffee' => '.js' do |target, source|
    coffee source, File.dirname(target)
  end

end
