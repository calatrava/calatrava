Given /^the following directories exist:$/ do |directories|
  directories.raw.each { |dir_row| create_dir(dir_row[0]) }
end

Given /^the following files exist:$/ do |files|
  files.raw.each { |file_row| write_file(file_row[0], "") }
end

