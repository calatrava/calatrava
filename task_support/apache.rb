require 'erb'

directory APACHE_LOGS_DIR

if `uname -a`.chomp["amzn1"]
  HTTPD = "httpd"
  MODULES_PATH = "/usr/lib64/httpd/modules"
  LOAD_LOG_MODULE = true
elsif `uname`.chomp == "Linux"
  HTTPD = "apache2"
  MODULES_PATH = "/usr/lib/apache2/modules"
  LOAD_LOG_MODULE = false
else
  HTTPD = "httpd"
  MODULES_PATH = "modules_mac"
  LOAD_LOG_MODULE = true
end

def configure_apache
    cp config_path("httpd.conf"), File.join(APACHE_DIR, 'conf')
end

def create_plist
  erb = ERB.new(File.read("#{APACHE_DIR}/com.jenkins.calatrava.apache.plist.erb"))
  File.open("#{APACHE_DIR}/com.jenkins.calatrava.apache.plist", "w") { |f| f.write(erb.result) }
end

def launch_apache
  puts
  puts "\t\t" + "*"*40
  puts "\t\t" + "***   STARTING APACHE ON PORT 8888   ***"
  puts "\t\t" + "*"*40
  puts

  exec %Q|#{HTTPD} -d #{APACHE_DIR} -f conf/httpd.conf -e DEBUG -DNO_DETACH -DFOREGROUND|
end

def reload_apache
  sh %{#{HTTPD} -d #{APACHE_DIR} -f conf/httpd.conf -k restart}
end

