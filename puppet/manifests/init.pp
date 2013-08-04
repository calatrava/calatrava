
stage { 'req-install': before => Stage['rvm-install'] }

class requirements {
  exec { "apt-update":
    command => "/usr/bin/apt-get -y update"
  }
  include java
  package { ["ant", "apache2"]:
    ensure => installed,
    require => Exec['apt-update']
  }
}

class installrvm {
  include rvm
  rvm::system_user { vagrant: ; }

  rvm_system_ruby {
    'ruby-1.9.3-p448':
      ensure => 'present',
      default_use => false;
  }
}

class installandroid {
  class {'android': user => 'vagrant'}

  android::platform { 'android-17': }

  file {"/home/vagrant/.bash_profile":
    owner   => vagrant,
    group   => vagrant,
    mode    => 0644,
    content => template("/vagrant/puppet/templates/.bash_profile"),
    require => Class['android'],
  }
}

class doinstall {
  class { requirements:
    stage => "req-install"
  }
  include installrvm
  include nodejs
  include installandroid
}

include doinstall
