# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.box_version = "1.1.0"
  config.vm.provision :shell, path: "provision.sh", privileged: false
  config.vm.network :private_network, ip: "192.168.35.38"
  config.vm.network :forwarded_port, guest: 22, host: 7299
  config.vm.synced_folder "./", "/vagrant", mount_options: ["dmode=775,fmode=664"]
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
end

# TODO : Before packaging up the box, SSH into the VM and run these commands:
# sudo apt-get clean
# sudo dd if=/dev/zero of=/EMPTY bs=1M
# sudo rm -f /EMPTY
# sudo su
# history -c && exit
# cat /dev/null > ~/.bash_history && history -c && exit
