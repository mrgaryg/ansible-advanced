# Defines our Vagrant environment
#
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.8.0"

# use two digits id below, please
nodes = [
  { :hostname => 'ansible1', :ip => '10.0.15.11', :id => '11', :memory => 1024 },
  # { :hostname => 'ansible2', :ip => '10.0.15.12', :id => '12', :memory => 1024 },
  # { :hostname => 'ansible3', :ip => '10.0.15.13', :id => '13', :memory => 1024 },
]

# Add required plugins
Vagrant.configure("2") do |config|
  required_plugins = %w( vagrant-vbguest vagrant-hostmanager vagrant-reload vagrant-disksize )
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

  config.linked_clone = true if Vagrant::VERSION =~ /^1.8/
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

  config.vm.box_check_update = false
  nodes.each do |node|
    config.vm.define node[:hostname], autostart: true do |node_config|
      nodename = node[:hostname]
      node_config.vm.box = "centos/7"
      node_config.vm.hostname = nodename
      node_config.vm.network :private_network, ip: node[:ip]
      node_config.vm.synced_folder ".", "/vagrant", type: "virtualbox", create: true
      node_config.vm.provider "virtualbox" do |vb|
        vb.memory = node[:memory]
        # Use VBoxManage to customize the VM.
        # Change video memory:
        vb.customize ["modifyvm", :id, "--vram", "8"]
        # Change ostype:
        vb.customize ["modifyvm", :id, "--ostype", "RedHat_64"]
        # VM is modified to have a host CPU execution cap of 50%,
        # meaning that no matter how much CPU is used in the VM,
        # no more than 50% would be used on your own host machine.
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]

      end
      # Set /etc/hosts in the guests on 'vagrant provision'
      node_config.vm.provision :hostmanager
      if nodename == "ansible1"
        # Disable selinux and firewalld
        # node_config.vm.provision :shell, path: "./vagrant_provisioner/install-awx-pre.sh"
        node_config.vm.provision :ansible do |ansible|
          # ansible.become = true
          ansible.verbose        = true
          # ansible.install        = true
          ansible.limit          = "ansible1" # "all" or only "nodes" group, etc.
          ansible.playbook = "./vagrant_provisioner/disable_system_services.yml"
        end

        # # SELinux on CentOS and RHEL requires a reboot
        node_config.vm.provision :reload

        # Install dependency packages
        node_config.vm.provision :ansible do |ansible|
          # ansible.become = true
          ansible.verbose        = true
          # ansible.install        = true
          # ansible.limit          = "ansible1" # "all" or only "nodes" group, etc.
          ansible.playbook = "./vagrant_provisioner/install_dependencies.yml"
        end
        # Install Docker CE

        # Install AWX
        # node_config.vm.provision :shell, path: "./vagrant_provisioner/install-awx-post.sh"
        # node_config.vm.provision :ansible_local do |ansible|
        #   # ansible.become = true
        #   ansible.verbose        = true
        #   ansible.install        = true
        #   # ansible.limit          = "ansible1" # "all" or only "nodes" group, etc.
        #   ansible.inventory_path = "/vagrant/awx/installer/inventory"
        #   ansible.playbook = "/vagrant/awx/installer/install.yml"
        # end

      end
    end
  end
  # create some windows servers
  # config.vm.provider "virtualbox" do |v|
  #   v.gui = true
  #   v.customize ["modifyvm", :id, "--memory", 2048]
  #   v.customize ["modifyvm", :id, "--cpus", 2]
  #   v.customize ["modifyvm", :id, "--vram", 128]
  #   v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  #   v.customize ["modifyvm", :id, "--accelerate3d", "on"]
  #   v.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
  #   v.linked_clone = true if Vagrant::VERSION =~ /^1.8/
  # end

  # # Sample win2016 server config
  maxWin16host = 1
  # https://docs.vagrantup.com/v2/vagrantfile/tips.html
  (1..maxWin16host).each do |i|
    config.vm.define "answinsrvr16#{i}", autostart: false do |node|
      node.vm.box               = "StefanScherer/windows_2016"
      node.vm.hostname          = "answin16#{i}"
      # node.vm.network "public_network"
      node.vm.network :private_network, ip: "10.0.15.2#{i}"
      node.vm.communicator      = "winrm"
      node.vm.guest             = :windows
      node.windows.halt_timeout = 25
      node.winrm.username       = "vagrant"
      node.winrm.password       = "vagrant"
      node.winrm.host           = "localhost"
      node.vm.network :forwarded_port, { :guest=>3389, :host=>3389, :id=>"rdp", :auto_correct=>true }
      node.vm.network :forwarded_port, { :guest=>5985, :host=>5985, :id=>"winrm", :auto_correct=>true }

      node.vm.provider "virtualbox" do |vb|
        # vb.linked_clone = true
        vb.memory = "4096"
        # Boot with GUI mode
        vb.gui = true
        # Use VBoxManage to customize the VM
        # Set video memory:
        vb.customize ["modifyvm", :id, "--vram", "64"]
        # Set ostype:
        vb.customize ["modifyvm", :id, "--ostype", "Windows2016_64"]
        # VM is modified to have a host CPU execution cap of 50%,
        # meaning that no matter how much CPU is used in the VM,
        # no more than 50% would be used on your own host machine.
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
        vb.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
      end
      node.vm.provision :hostmanager
    end
  end
  # Spinup Windows Server 2019. Inspired by the following repo
  # https://github.com/mrgaryg/docker-windows-box.git
  # maxWin19host = 1
  # # https://docs.vagrantup.com/v2/vagrantfile/tips.html
  # (1..maxWin19host).each do |i|
  #   config.vm.define "win19#{i}", autostart: false do |node|
  #     node.vm.box = "StefanScherer/windows_2019"
  #     node.vm.communicator = "winrm"
  #     node.vm.hostname = "win19#{i}"
  #     node.vm.network "public_network"
  #     node.vm.network :private_network, ip: "10.0.15.1#{i}"
  #     node.vm.network "forwarded_port", guest: 80, host: "808#{i}"
  #     node.vm.provider "virtualbox" do |vb|
  #       vb.linked_clone = true
  #       vb.memory = "4096"
  #       # Don't boot with headless mode
  #       vb.gui = true
  #       # Use VBoxManage to customize the VM.
  #       # Change video memory:
  #       vb.customize ["modifyvm", :id, "--vram", "64"]
  #       # Change ostype:
  #       vb.customize ["modifyvm", :id, "--ostype", "Windows2019_64"]
  #       # VM is modified to have a host CPU execution cap of 50%,
  #       # meaning that no matter how much CPU is used in the VM,
  #       # no more than 50% would be used on your own host machine.
  #       vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
  #     end
  #     node.vm.provision :hostmanager
  #   end
  # end

end
