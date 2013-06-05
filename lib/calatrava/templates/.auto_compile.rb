if Gem::Specification.find_all_by_name('filewatcher').count > 0
  require 'filewatcher'
  FileWatcher.new(Dir["kernel/app/**/*.coffee", "kernel/plugins/**/*coffee", "shell/**/*.coffee"]).watch do |filename|
    puts "Recompiling file " + filename
    system "node_modules/coffee-script/bin/coffee --compile --output web/public/scripts #{filename}"
  end
else
  $stderr.puts("*"*100)
  $stderr.puts("File watcher gem is not present as part of gem set. Your kernel and shell files won't be auto compiled.")
  $stderr.puts("*"*100)
end