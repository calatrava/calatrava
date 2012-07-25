def coffee(in_dir, out_dir)
  if !Dir["#{in_dir}/**/*.coffee"].empty?
    $stdout.puts "coffee #{in_dir} -> #{out_dir}"
    sh "node_modules/coffee-script/bin/coffee --compile --output #{out_dir} #{in_dir}"
  end
end
