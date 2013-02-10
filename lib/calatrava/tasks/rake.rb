require 'digest/sha1'

module Rake
  module DSL

    def transient(name, value)
      transients = File.join('.rake', 'transients')
      FileUtils.mkdir_p transients
      value_file = File.join(transients, name.to_s)
      value_hash = Digest::SHA1.hexdigest(value.to_s)
      if File.exists? value_file
        previous_hash = IO.read(value_file)
        FileUtils.rm value_file if previous_hash != value_hash
      end

      file value_file do
        File.open(value_file, "w+") { |f| f.print value_hash }
      end
      task name => value_file
    end

  end

end
