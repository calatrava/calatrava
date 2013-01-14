module Calatrava
  def self.platform
    case RbConfig::CONFIG['host_os']
    when /darwin/
      :mac
    when /linux/
      :linux
    else
      raise "Unsupported OS"
    end
  end
end
