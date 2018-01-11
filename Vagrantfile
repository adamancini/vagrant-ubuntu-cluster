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
  config.vm.define "haproxy" do |haproxy_node|
    config.vm.provider :virtualbox do |vb|
       vb.customize ["modifyvm", :id, "--memory", "1024"]
       vb.customize ["modifyvm", :id, "--cpus", "1"]
       vb.name = "ubuntu-haproxy-node"
    end
    config.vm.provider :libvirt do |domain|
      domain.memory = "1024"
      domain.cpus = 1
      domain.host = "haproxy"
    end
    config.ssh.insert_key = false
    haproxy_node.vm.box = "yk0/ubuntu-xenial"
    haproxy_node.vm.network "private_network", :ip => "172.28.2.30"
    haproxy_node.vm.hostname = "haproxy.landrush"
    haproxy_node.hostsupdater.aliases = ["ucp.landrush", "dtr.landrush"]
    haproxy_node.vm.provision "shell", inline: <<-SHELL
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
  config.vm.define "ucp-node1" do |ubuntu_ucp_node1|
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
      vb.name = "ubuntu-ucp-node1"
    end
    config.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 2
      domain.host = "ucp-node1"
    end
    ubuntu_ucp_node1.vm.box = "yk0/ubuntu-xenial"
    ubuntu_ucp_node1.vm.network "private_network", ip: "172.28.2.31"
    ubuntu_ucp_node1.vm.hostname = "ucp-node1.landrush"
    ubuntu_ucp_node1.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/install_ucp.sh .
      sudo cp /vagrant/scripts/create_tokens.sh .
      sudo cp /vagrant/scripts/visualizer.sh .
      sudo cp /vagrant/files/ucp_images_2.1.4.tar.gz .
      sudo chmod +x install_ee.sh
      sudo chmod +x install_ucp.sh
      sudo chmod +x create_tokens.sh
      sudo chmod +x visualizer.sh
      ./install_ee.sh
      ./install_ucp.sh
      ./create_tokens.sh
      # ./visualizer.sh
   SHELL
  end

  # # Docker EE node for ubuntu 7.3
  # config.vm.define "ucp-node2" do |ubuntu_ucp_node2|
  #   config.vm.provider :virtualbox do |vb|
  #     vb.customize ["modifyvm", :id, "--memory", "2048"]
  #     vb.customize ["modifyvm", :id, "--cpus", "2"]
  #     vb.name = "ubuntu-ucp-node2"
  #   end
  #   ubuntu_ucp_node2.vm.box = "yk0/ubuntu-xenial"
  #   ubuntu_ucp_node2.vm.network "private_network", ip: "172.28.2.32"

  #   ubuntu_ucp_node2.vm.hostname = "ucp-node2.landrush"
  #   ubuntu_ucp_node2.landrush.enabled = true
  #   ubuntu_ucp_node2.vm.provision "shell", inline: <<-SHELL
  #     sudo apt-get update
  #     sudo apt-get install -y apt-transport-https ca-certificates ntpdate
  #     sudo ntpdate -s time.nist.gov
  #     sudo cp /vagrant/scripts/install_ee.sh .
  #     sudo cp /vagrant/scripts/join_manager.sh .
  #     sudo cp /vagrant/files/ucp_images_2.1.4.tar.gz .
  #     sudo chmod +x install_ee.sh
  #     sudo chmod +x join_manager.sh
  #     ./install_ee.sh
  #     ./join_manager.sh
  #   SHELL
  # end

  # # Docker EE node for ubuntu 7.3
  # config.vm.define "ucp-node3" do |ubuntu_ucp_node3|
  #   config.vm.provider :virtualbox do |vb|
  #     vb.customize ["modifyvm", :id, "--memory", "2048"]
  #     vb.customize ["modifyvm", :id, "--cpus", "2"]
  #     vb.name = "ubuntu-ucp-node3"
  #   end
  #   ubuntu_ucp_node3.vm.box = "yk0/ubuntu-xenial"
  #   ubuntu_ucp_node3.vm.network "private_network", ip: "172.28.2.33"

  #   ubuntu_ucp_node3.vm.hostname = "ucp-node3.landrush"
  #   ubuntu_ucp_node3.landrush.enabled = true
  #   ubuntu_ucp_node3.vm.provision "shell", inline: <<-SHELL
  #     sudo apt-get update
  #     sudo apt-get install -y apt-transport-https ca-certificates ntpdate
  #     sudo ntpdate -s time.nist.gov
  #     sudo cp /vagrant/scripts/install_ee.sh .
  #     sudo cp /vagrant/scripts/join_manager.sh .
  #     sudo cp /vagrant/files/ucp_images_2.1.4.tar.gz .
  #     sudo chmod +x install_ee.sh
  #     sudo chmod +x join_manager.sh
  #     ./install_ee.sh
  #     ./join_manager.sh
  #  SHELL
  # end

  # Docker EE node for ubuntu 7.3
  config.vm.define "dtr-node1" do |ubuntu_dtr_node1|
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
      vb.name = "ubuntu-dtr-node1"
    end
    config.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 2
      domain.host = "dtr-node1"
    end
    ubuntu_dtr_node1.vm.box = "yk0/ubuntu-xenial"
    ubuntu_dtr_node1.vm.network "private_network", ip: "172.28.2.34"
    ubuntu_dtr_node1.vm.hostname = "dtr-node1.landrush"
    ubuntu_dtr_node1.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_worker.sh .
      sudo cp /vagrant/scripts/install_dtr.sh .
      sudo cp /vagrant/scripts/prepopulate_dtr.sh .
      sudo cp /vagrant/scripts/backup_dtr.sh .
      sudo cp /vagrant/files/ucp_images_2.1.4.tar.gz .
      sudo cp /vagrant/files/dtr-2.2.5.tar.gz
      sudo chmod +x install_ee.sh
      sudo chmod +x join_worker.sh
      sudo chmod +x install_dtr.sh
      sudo chmod +x prepopulate_dtr.sh
      sudo chmod +x backup_dtr.sh
      ./install_ee.sh
      ./join_worker.sh
      ./install_dtr.sh
    SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "worker-node1" do |ubuntu_worker_node1|
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1500"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
      vb.name = "ubuntu-worker-node1"
    end
    config.vm.provider :libvirt do |domain|
      domain.memory = "1500"
      domain.cpus = 1
      domain.host = "worker-node1"
    end
    ubuntu_worker_node1.vm.box = "yk0/ubuntu-xenial"
    ubuntu_worker_node1.vm.network "private_network", ip: "172.28.2.35"
    ubuntu_worker_node1.vm.hostname = "worker-node1.landrush"
    ubuntu_worker_node1.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_worker.sh .
      sudo cp /vagrant/files/ucp_images_2.1.4.tar.gz .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_worker.sh
      ./install_ee.sh
      ./join_worker.sh
   SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "worker-node2" do |ubuntu_worker_node2|
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1500"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
      vb.name = "ubuntu-worker-node2"
    end
    config.vm.provider :libvirt do |domain|
      domain.memory = "1500"
      domain.cpus = 1
      domain.host = "worker-node2"
    end
    ubuntu_worker_node2.vm.box = "yk0/ubuntu-xenial"
    ubuntu_worker_node2.vm.network "private_network", ip: "172.28.2.36"
    ubuntu_worker_node2.vm.hostname = "worker-node2.landrush"
    ubuntu_worker_node2.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_worker.sh .
      sudo cp /vagrant/files/ucp_images_2.1.4.tar.gz .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_worker.sh
      sleep 5
      ./install_ee.sh
      ./join_worker.sh
   SHELL
  end

  # Docker EE node for ubuntu 7.3
  # config.vm.define "worker-node3" do |ubuntu_worker_node3|
  #   config.vm.provider :virtualbox do |vb|
  #     vb.customize ["modifyvm", :id, "--memory", "1500"]
  #     vb.customize ["modifyvm", :id, "--cpus", "2"]
  #     vb.name = "ubuntu-worker-node3"
  #   end
  #   ubuntu_worker_node3.vm.box = "yk0/ubuntu-xenial"
  #   ubuntu_worker_node3.vm.network "private_network", ip: "172.28.2.39"
  #   ubuntu_worker_node3.vm.hostname = "worker-node3.landrush"
  #   ubuntu_worker_node3.vm.provision "shell", inline: <<-SHELL
  #     export DEBIAN_FRONTEND=noninteractive
  #     sudo apt-get update
  #     sudo apt-get install -y apt-transport-https ca-certificates ntpdate
  #     sudo ntpdate -s time.nist.gov
  #     sudo cp /vagrant/scripts/install_ee.sh .
  #     sudo cp /vagrant/scripts/join_worker.sh .
  #     sudo cp /vagrant/files/ucp_images_2.1.4.tar.gz .
  #     sudo chmod +x install_ee.sh
  #     sudo chmod +x join_worker.sh
  #     sleep 5
  #     # ./install_ee.sh
  #     # ./join_worker.sh
  #  SHELL
  # end
end
