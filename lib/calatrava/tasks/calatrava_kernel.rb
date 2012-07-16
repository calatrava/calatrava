module CalatravaKernel
  
  def self.modules
    Dir['kernel/app/*'].select { |n| File.directory? n }.collect { |n| File.basename n }
  end

  def self.src_paths
    modules.collect { |m| "app/#{m}" }.join(':')
  end

end
