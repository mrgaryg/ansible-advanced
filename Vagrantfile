# Defines our Vagrant environment
#
# -*- mode: ruby -*-
# vi: set ft=ruby :

# use two digits id below, please
nodes = [
  { :hostname => 'ansible1', :ip => '10.0.15.11', :id => '11', :memory => 256 },
  { :hostname => 'ansible2', :ip => '10.0.15.12', :id => '12', :memory => 256 },
  { :hostname => 'ansible3', :ip => '10.0.15.13', :id => '13', :memory => 256 },
]

Vagrant.configure("2") do |config|
  required_plugins = %w( vagrant-vbguest vagrant-disksize vagrant-hostmanager )
  _retry = false
  required_plugins.each do |plugin|
      unless Vagrant.has_plugin? plugin
          system "vagrant plugin install #{plugin}"
          _retry=true
      end
  end

  if (_retry)
      exec "vagrant " + ARGV.join(' ')
  end

  config.ssh.insert_key = false
  # Manage /etc/hosts on the guests
  config.hostmanager.enabled = true # Set /etc/hosts in the guests on 'vagrant up'
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  # configure proxy settings if 'vagrant-proxyconf' plugin is intalled
  # if Vagrant.has_plugin?("vagrant-proxyconf")
  #   config.proxy.http     = "http://192.168.0.2:3128/"
  #   config.proxy.https    = "http://192.168.0.2:3128/"
  #   config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"
  # end

  nodes.each do |node|
    config.vm.define node[:hostname], autostart: true do |node_config|
      nodename = node[:hostname]
      node_config.vm.box = "centos/7"
      node_config.vm.hostname = nodename
      node_config.vm.network :private_network, ip: node[:ip]
      node_config.vm.synced_folder ".", "/vagrant", type: "virtualbox", create: true
      node_config.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory = node[:memory]
        # Use VBoxManage to customize the VM.
        # Change video memory:
        vb.customize ["modifyvm", :id, "--vram", "64"]
        # Change ostype:
        vb.customize ["modifyvm", :id, "--ostype", "RedHat_64"]
        # VM is modified to have a host CPU execution cap of 50%,
        # meaning that no matter how much CPU is used in the VM,
        # no more than 50% would be used on your own host machine.
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]

      end
      # Set /etc/hosts in the guests on 'vagrant provision'
      node_config.vm.provision :hostmanager
      # if nodename == "mgmt"
      #   node_config.vm.provision :shell, path: "bootstrap-mgmt.sh"
      # end
    end
  end
  # create some windows servers
  maxWinhost = 1
  # https://docs.vagrantup.com/v2/vagrantfile/tips.html
  (1..maxWinhost).each do |i|
    config.vm.define "answinsrvr16#{i}", autostart: false do |node|
      node.vm.box = "jmv74211/windows2016"
      node.vm.box_version = "1.0"
      node.vm.hostname = "answin16#{i}"
      node.vm.network :private_network, ip: "10.0.15.2#{i}"
      node.vm.network "forwarded_port", guest: 80, host: "808#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory = "2048"
        # Don't boot with headless mode
        vb.gui = true
        # Use VBoxManage to customize the VM.
        # Change video memory:
        vb.customize ["modifyvm", :id, "--vram", "64"]
        # Change ostype:
        vb.customize ["modifyvm", :id, "--ostype", "Windows2016_64"]
        # VM is modified to have a host CPU execution cap of 50%,
        # meaning that no matter how much CPU is used in the VM,
        # no more than 50% would be used on your own host machine.
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
      end
      node.vm.provision :hostmanager
    end
  end

end
