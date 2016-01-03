# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.box_version = "1.1.0"
  config.vm.provision :shell, path: "provision.sh", privileged: false
end

# TODO : Before packaging up the box, SSH into the VM and run these commands:
# sudo apt-get clean
# sudo dd if=/dev/zero of=/EMPTY bs=1M
# sudo rm -f /EMPTY
# sudo su
# history -c && exit
# cat /dev/null > ~/.bash_history && history -c && exit
