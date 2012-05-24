def coffee(in_dir, out_dir)
  sh "coffee --compile --output #{out_dir} #{in_dir}"
end