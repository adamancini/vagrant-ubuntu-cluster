# -*- mode: ruby -*-
# vi: set ft=ruby :
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

Vagrant.configure(2) do |config|

  ### Environment Settings
  config.vm.provider :libvirt do |l|
    # l.username = "vagrant"
    # l.password = 'vagrant'
    # l.connect_via_ssh = true
    l.driver = "kvm"
    l.uri = 'qemu+unix:///system'
    # l.id_ssh_key_file = "/home/ada/.ssh/vagrant"
    l.storage_pool_name = "ubuntu-swarm"
  end
  config.vm.provider :virtualbox do |v|
    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end

  # don't remove entries from /etc/hosts on suspend
  config.hostsupdater.remove_on_suspend = false
  config.landrush.guest_redirect_dns = false
  config.vm.synced_folder ".", "/vagrant",
    type: 'nfs',
    nfs_version: '3',
    nfs_udp: false,
    linux__nfs_options: ['rw','no_subtree_check','all_squash','async','insecure']
  config.vm.synced_folder "~/docker/support-tools", "/support-tools",
    # rsync__exclude: ".git/"
    type: 'nfs',
    nfs_version: '3',
    nfs_udp: false,
    linux__nfs_options: ['rw','no_subtree_check','all_squash','async','insecure']
  config.landrush.enabled = true
  config.landrush.tld = 'landrush'
  config.landrush.host 'dtr.landrush', '172.28.2.30'
  config.landrush.host 'ucp.landrush', '172.28.2.30'


  ### Virtual Machine definitions

  # Docker EE node for ubuntu 7.3
  config.vm.define "haproxy" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "1024"
      domain.cpus = 1
      domain.host = "haproxy"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", :ip => "172.28.2.30"
    node.vm.hostname = "haproxy.landrush"
    node.hostsupdater.aliases = ["ucp.landrush", "dtr.landrush"]
    node.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo apt-get install -y software-properties-common
      sudo add-apt-repository ppa:vbernat/haproxy-1.7
      sudo apt-get update
      sudo apt-get install -y haproxy
      # ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' > /vagrant/haproxy-node
      sudo sed -i '/module(load="imudp")/s/^#//g' /etc/rsyslog.conf
      sudo sed -i '/input(type="imudp" port="514")/s/^#//g' /etc/rsyslog.conf
      sudo service rsyslog restart
      sudo cp /vagrant/files/haproxy.cfg /etc/haproxy/haproxy.cfg
      sudo service haproxy restart
    SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-node1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 2
      domain.host = "ucp-node1"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.31"
    node.vm.hostname = "ucp-node1.landrush"
    node.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/install_ucp.sh .
      sudo cp /vagrant/scripts/create_tokens.sh .
      sudo chmod +x install_ee.sh
      sudo chmod +x install_ucp.sh
      sudo chmod +x create_tokens.sh
      ./install_ee.sh
      ./install_ucp.sh
      ./create_tokens.sh
   SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-node2" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 2
      domain.host = "ucp-node2"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.32"
    node.vm.hostname = "ucp-node2.landrush"
    node.landrush.enabled = true
    node.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_manager.sh .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_manager.sh
      ./install_ee.sh
      ./join_manager.sh
    SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-node3" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 2
      domain.host = "ucp-node3"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.33"
    node.vm.hostname = "ucp-node3.landrush"
    node.landrush.enabled = true
    node.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_manager.sh .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_manager.sh
      ./install_ee.sh
      ./join_manager.sh
   SHELL
  end

  config.vm.define "dtr-node1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 2
      domain.host = "dtr-node1"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.34"
    node.vm.hostname = "dtr-node1.landrush"
    node.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_worker.sh .
      sudo cp /vagrant/scripts/install_dtr.sh .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_worker.sh
      sudo chmod +x install_dtr.sh
      ./install_ee.sh
      ./join_worker.sh
      ./install_dtr.sh
    SHELL
  end

  config.vm.define "worker-node1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "1500"
      domain.cpus = 1
      domain.host = "worker-node1"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.35"
    node.vm.hostname = "worker-node1.landrush"
    node.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_worker.sh .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_worker.sh
      ./install_ee.sh
      ./join_worker.sh
   SHELL
  end

  config.vm.define "worker-node2" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "1500"
      domain.cpus = 1
      domain.host = "worker-node2"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.36"
    node.vm.hostname = "worker-node2.landrush"
    node.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_worker.sh .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_worker.sh
      sleep 5
      ./install_ee.sh
      ./join_worker.sh
   SHELL
  end

  config.vm.define "worker-node3" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "1500"
      domain.cpus = 1
      domain.host = "worker-node3"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.37"
    node.vm.hostname = "worker-node3.landrush"
    node.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_worker.sh .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_worker.sh
      sleep 5
      ./install_ee.sh
      ./join_worker.sh
   SHELL
  end
end
