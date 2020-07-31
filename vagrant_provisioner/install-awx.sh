#!/bin/bash

# This has been replaced disable_selinux.yml playbook
# sudo systemctl disable --now firewalld
# sudo setenforce 0
# # disable selinux
# # sudo vim /etc/sysconfig/selinux
# sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config


# echo "install and setup epel"
# sudo yum install -y epel-release
# echo "install ansible, dependencies and other ad-hoc packages"
# sudo yum install -y git ansible python3 pip3 bash-completion python3-devel python3-pip python-docker-py vim-enhanced redhat-lsb-core
# sudo yum install -y yum-utils device-mapper-persistent-data lvm2


# Install Docker
# remove podman if running RHEL or CentOS 8
[[ `lsb_release -r | awk '{print $2}' | egrep '^8'` ]] && sudo yum -y remove podman

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable --now docker
newgrp docker
sudo usermod -aG docker vagrant
sudo pip3 install docker-compose

echo "get awx repo..."
# make sure we don't have an awx direcotry left over
echo "my id is: `whoami`"
[[ -d awx ]] && rm -rf awx
git clone https://github.com/ansible/awx
echo "setup awx"
cd awx/installer/
# make sure to review the desired variable ettings in the inventory file
# sudo ansible-playbook -i inventory install.yml
# sudo poweroff

