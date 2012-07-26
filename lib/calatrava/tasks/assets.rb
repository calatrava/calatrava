def coffee(in_dir_or_file, out_dir)
  if !Dir["#{in_dir_or_file}/**/*.coffee"].empty? || File.exists?(in_dir_or_file)
    $stdout.puts "coffee #{in_dir_or_file} -> #{out_dir}"
    sh "node_modules/coffee-script/bin/coffee --compile --output #{out_dir} #{in_dir_or_file}"
  end
end
