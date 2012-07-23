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
  MODULES_PATH = "/usr/libexec/apache2"
  LOAD_LOG_MODULE = true
end

def httpd(command)
  exec %Q|#{HTTPD} -d #{APACHE_DIR} -f conf/httpd.conf -e DEBUG -k #{command} -DNO_DETACH -DFOREGROUND|
end

def configure_apache
  cp config_path("httpd.conf"), File.join(APACHE_DIR, 'conf')
end

def launch_apache
  puts
  puts "\t\t" + "*"*40
  puts "\t\t" + "***   STARTING APACHE ON PORT 8888   ***"
  puts "\t\t" + "*"*40
  puts

  httpd :start
end

def stop_apache
  httpd :stop
end

def reload_apache
  httpd :restart
end

