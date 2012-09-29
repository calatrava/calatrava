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

def httpd(command, opts = {})
  cmd = %Q{#{HTTPD} -d #{APACHE_DIR} -f conf/httpd.conf -e DEBUG -k #{command} -DNO_DETACH -DFOREGROUND}
  puts cmd
  if opts[:background]
    fork do
      exec cmd
    end
  else
    exec cmd
  end
end

def configure_apache
  cp config_path("httpd.conf"), File.join(APACHE_DIR, 'conf')
end

def launch_apache(opts = {})
  if !opts[:background]
    puts
    puts "\t\t" + "*"*40
    puts "\t\t" + "***   STARTING APACHE ON PORT 8888   ***"
    puts "\t\t" + "*"*40
    puts
  end

  httpd :start, opts
end

def stop_apache
  httpd 'graceful-stop'
end

def reload_apache
  httpd :restart
end

