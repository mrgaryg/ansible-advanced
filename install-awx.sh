#!/bin/bash

sudo systemctl disable --now firewalld
sudo setenforce 0
# disable selinux
# sudo vim /etc/sysconfig/selinux
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

sudo yum install -y git vim
echo "install and setup epel"
sudo yum install -y epel-release
echo "install ansible, depndencies and other ad-hoc packages"
sudo yum install -y ansible python3 pip3 bash-completion python3-devel python3-pip python-docker-py vim-enhanced redhat-lsb-core
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
# If running RHEL or CentOS 8 remove podman
[[ `lsb_release -r | awk '{print $2}' | egrep '^8'` ]] && sudo yum -y remove podman

sudo yum -y install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable --now docker
newgrp docker
sudo usermod -aG docker vagrant
# sudo ln -s /usr/bin/python3 /usr/bin/python
sudo pip3 install docker-compose
sudo git clone https://github.com/ansible/awx
cd awx/installer/
# sudo vim inventory
sudo ansible-playbook -i inventory install.yml
sudo poweroff
