def cp_ne(source, dest_dir)
  cp Dir[source], dest_dir
end

def coffee(in_dir_or_file, out_dir)
  if !Dir["#{in_dir_or_file}/**/*.coffee"].empty? || File.exists?(in_dir_or_file)
    $stdout.puts "coffee #{in_dir_or_file} -> #{out_dir}"
    ok = system "node_modules/coffee-script/bin/coffee --compile --output #{out_dir} #{in_dir_or_file}"
    fail "Error compiling coffee script. Did you run `npm install`?" if !ok
  end
end
