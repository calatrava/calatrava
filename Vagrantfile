# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'precise64-ubuntu-12.04LTS'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box'

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on'] # Host OS's resolve. Includes /etc/hosts entries
    vb.customize ['modifyvm', :id, '--memory', '1024']
  end

  config.vm.network :private_network, ip: '172.16.1.1'
  config.vm.network :forwarded_port, guest: 8888, host: 8888

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path    = 'puppet/modules'
    puppet.manifest_file  = 'init.pp'
  end
end
