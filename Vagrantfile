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
  config.landrush.guest_redirect_dns = true
  config.landrush.host_interface_class = :ipv4
  config.landrush.host_interface = 'eth1'

  config.vm.synced_folder ".", "/vagrant",
    type: 'nfs',
    nfs_version: '3',
    nfs_udp: false,
    linux__nfs_options: ['rw','no_subtree_check','all_squash','async','insecure']
  config.vm.synced_folder "~/docker", "/docker",
    # rsync__exclude: ".git/"
    type: 'nfs',
    nfs_version: '3',
    nfs_udp: false,
    linux__nfs_options: ['rw','no_subtree_check','all_squash','async','insecure']
  config.landrush.enabled = true
  config.landrush.tld = 'local.antiskub.net'
  config.landrush.host 'dtr.local.antiskub.net', '172.28.2.30'
  config.landrush.host 'ucp.local.antiskub.net', '172.28.2.30'

  ## Try to automatically generate ansible host inventory by calling vm.provision without a playbook
  config.vm.provision :ansible do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "playbooks/apt-update.yaml"
    ansible.groups = {
      "managers"       => ["ucp-node1","ucp-node2","ucp-node3"],
      "workers"        => ["worker-node1","worker-node2","worker-node3"],
      "proxy"          => ["haproxy"],
      "swarm:children" => ["managers","workers"]
    }
  end

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
    node.vm.hostname = "haproxy.local.antiskub.net"
    node.hostsupdater.aliases = ["ucp.local.antiskub.net", "dtr.local.antiskub.net"]
    node.vm.provision "shell", inline: <<-SHELL
      add-apt-repository ppa:vbernat/haproxy-1.7
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates ntpdate haproxy software-properties-common
      ntpdate -s time.nist.gov
      # ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' > /vagrant/haproxy-node
      sed -i '/module(load="imudp")/s/^#//g' /etc/rsyslog.conf
      sed -i '/input(type="imudp" port="514")/s/^#//g' /etc/rsyslog.conf
      service rsyslog restart
      cp /vagrant/files/haproxy.cfg /etc/haproxy/haproxy.cfg
      service haproxy restart
    SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-node1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "4096"
      domain.cpus = 2
      domain.host = "ucp-node1"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.31"
    node.vm.hostname = "ucp-node1.local.antiskub.net"
    node.vm.provision "shell", inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates ntpdate
      ntpdate -s time.nist.gov
      /vagrant/scripts/install_ee.sh
      /vagrant/scripts/install_ucp.sh
      /vagrant/scripts/create_tokens.sh
   SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-node2" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "4096"
      domain.cpus = 2
      domain.host = "ucp-node2"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.32"
    node.vm.hostname = "ucp-node2.local.antiskub.net"
    node.landrush.enabled = true
    node.vm.provision "shell", inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates ntpdate
      ntpdate -s time.nist.gov
      /vagrant/scripts/install_ee.sh
      /vagrant/scripts/join_manager.sh
    SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-node3" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "4096"
      domain.cpus = 2
      domain.host = "ucp-node3"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.33"
    node.vm.hostname = "ucp-node3.local.antiskub.net"
    node.landrush.enabled = true
    node.vm.provision "shell", inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates ntpdate
      ntpdate -s time.nist.gov
      /vagrant/scripts/install_ee.sh
      /vagrant/scripts/join_manager.sh
   SHELL
  end

  config.vm.define "dtr-node1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "4096"
      domain.cpus = 2
      domain.host = "dtr-node1"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.34"
    node.vm.hostname = "dtr-node1.local.antiskub.net"
    node.vm.provision "shell", inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates ntpdate
      ntpdate -s time.nist.gov
      /vagrant/scripts/install_ee.sh
      /vagrant/scripts/join_worker.sh
      /vagrant/scripts/install_dtr.sh
    SHELL
  end

  config.vm.define "worker-node1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 1
      domain.host = "worker-node1"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.35"
    node.vm.hostname = "worker-node1.local.antiskub.net"
    node.vm.provision "shell", inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates ntpdate
      ntpdate -s time.nist.gov
      /vagrant/scripts/install_ee.sh
      /vagrant/scripts/join_worker.sh
   SHELL
  end

  config.vm.define "worker-node2" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 1
      domain.host = "worker-node2"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.36"
    node.vm.hostname = "worker-node2.local.antiskub.net"
    node.vm.provision "shell", inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates ntpdate
      ntpdate -s time.nist.gov
      sleep 5
      /vagrant/scripts/install_ee.sh
      /vagrant/scripts/join_worker.sh
   SHELL
  end

  config.vm.define "worker-node3" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 1
      domain.host = "worker-node3"
    end
    node.vm.box = "yk0/ubuntu-xenial"
    node.vm.network "private_network", ip: "172.28.2.37"
    node.vm.hostname = "worker-node3.local.antiskub.net"
    node.vm.provision "shell", inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates ntpdate
      ntpdate -s time.nist.gov
      sleep 5
      /vagrant/scripts/install_ee.sh
      /vagrant/scripts/join_worker.sh
   SHELL
  end
end
