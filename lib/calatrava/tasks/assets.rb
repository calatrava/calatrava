def coffee(in_dir, out_dir)
  sh "node_modules/coffee-script/bin/coffee --compile --output #{out_dir} #{in_dir}" unless Dir["in_dir/**/*.coffee"].empty?
end
