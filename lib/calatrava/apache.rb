module Calatrava

  class Apache
    include Rake::DSL

    Calatrava::Configuration.extra do |c|
      c.runtime :apache_2_dot_2, system('httpd -v | grep Apache/2.2 >> /dev/null')
      if `uname -a`.chomp["amzn1"]
        c.runtime :modules_path, "/usr/lib64/httpd/modules"
        c.runtime :load_log_module, true
      elsif `uname`.chomp == "Linux"
        c.runtime :modules_path, "/usr/lib/apache2/modules"
        c.runtime :load_log_module, false
      elsif `uname`.chomp == "Darwin"
        c.runtime :modules_path, "/usr/libexec/apache2"
        c.runtime :load_log_module, true
      else
        raise "Calatrava does not support running apache on this platform."
      end
    end
    
    def apache_dir ; "web/apache" ; end
    def apache_public_dir ; "#{apache_dir}/public" ; end
    def apache_logs_dir ; "#{apache_dir}/logs" ; end
    def apache_conf_dir ; "#{apache_dir}/conf"; end

    def httpd(command, opts = {})
      ensure_httpd
      cmd = %Q{#{@httpd} -d #{apache_dir} -f conf/httpd.conf -e DEBUG -k #{command} -DNO_DETACH -DFOREGROUND}
      puts cmd
      if opts[:background]
        fork do
          exec cmd
        end
      else
        exec cmd
      end
    end

    def launch_apache(opts = {})
      httpd :start, opts
    end

    def stop_apache
      httpd 'graceful-stop'
    end

    def reload_apache
      httpd :restart
    end

    def ensure_httpd
      if !@httpd
        if `uname -a`.chomp["amzn1"]
          @httpd = "httpd"
        elsif `uname`.chomp == "Linux"
          @httpd = "apache2"
        elsif `uname`.chomp == "Darwin"
          @httpd = "httpd"
        else
          raise "Calatrava does not support running apache on this platform."
        end
      end
    end

    def install_tasks
      directory apache_logs_dir
      file apache_public_dir do
        cd apache_dir do
          ln_s "../public", "public"
        end
      end

      file "#{apache_conf_dir}/httpd.conf" => 'configure:calatrava_env' do
        cp Calatrava::Project.current.config.path("httpd.conf"), apache_conf_dir
      end

      desc "launch a non-daemon apache instance on port 8888 which will serve our local app and also proxy to backend services"
      task :start => ['web:build', apache_public_dir, apache_logs_dir, "#{apache_conf_dir}/httpd.conf", 'web:autocompile'] do
        launch_apache
      end

      task :background => ['web:build', apache_public_dir, apache_logs_dir, "#{apache_conf_dir}/httpd.conf"] do
        launch_apache :background => true
      end

      desc "Reload the apache configuration"
      task :reload do
        reload_apache
      end

      desc "Stop the apache configuration"
      task :stop do
        stop_apache
      end

      desc "Cleans apache config"
      task :clean do
        rm_rf apache_logs_dir
        rm_rf File.join(apache_conf_dir, 'httpd.conf')
      end

    end
  end

end
