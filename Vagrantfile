# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.provider :virtualbox do |v|
    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end
  config.hostsupdater.remove_on_suspend = false

  # Docker EE node for ubuntu 7.3
  config.vm.define "haproxy" do |haproxy_node|
    config.vm.provider :virtualbox do |vb|
       vb.customize ["modifyvm", :id, "--memory", "1024"]
       vb.customize ["modifyvm", :id, "--cpus", "1"]
       vb.name = "ubuntu-haproxy-node"
    end
    haproxy_node.vm.box = "ubuntu/xenial64"
    haproxy_node.vm.network "private_network", ip: "172.28.128.30"
    haproxy_node.vm.hostname = "haproxy.local"
    haproxy_node.hostsupdater.aliases = ["ucp.local", "dtr.local"]
    haproxy_node.landrush.enabled = true
    haproxy_node.landrush.tld = 'local'
    haproxy_node.landrush.host 'dtr.local', '172.28.128.30'
    haproxy_node.landrush.host 'ucp.local', '172.28.128.30'
    haproxy_node.landrush.host 'wordpress.local', '172.28.128.31'
    haproxy_node.landrush.host 'jenkins.local', '172.28.128.31'
    haproxy_node.landrush.host 'nodeapp.local', '172.28.128.31'
    haproxy_node.landrush.host 'visualizer.local', '172.28.128.31'
    haproxy_node.vm.provision "shell", inline: <<-SHELL
     sudo apt-get update
     sudo apt-get install -y apt-transport-https ca-certificates ntpdate
     sudo ntpdate -s time.nist.gov
     sudo apt-get install -y software-properties-common
     sudo add-apt-repository ppa:vbernat/haproxy-1.7
     sudo apt-get update
     sudo apt-get install -y haproxy
     ifconfig enp0s8 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' > /vagrant/haproxy-node
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
    ubuntu_ucp_node1.vm.box = "ubuntu/xenial64"
    ubuntu_ucp_node1.vm.network "private_network", ip: "172.28.128.31"
    ubuntu_ucp_node1.landrush.tld = 'local'
    ubuntu_ucp_node1.vm.hostname = "ucp-node1.local"
    ubuntu_ucp_node1.landrush.enabled = true
    ubuntu_ucp_node1.vm.provision "shell", inline: <<-SHELL
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
  #   ubuntu_ucp_node2.vm.box = "ubuntu/xenial64"
  #   ubuntu_ucp_node2.vm.network "private_network", ip: "172.28.128.32"
  #   ubuntu_ucp_node2.landrush.tld = 'local'
  #   ubuntu_ucp_node2.vm.hostname = "ucp-node2.local"
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
  #   ubuntu_ucp_node3.vm.box = "ubuntu/xenial64"
  #   ubuntu_ucp_node3.vm.network "private_network", ip: "172.28.128.33"
  #   ubuntu_ucp_node3.landrush.tld = 'local'
  #   ubuntu_ucp_node3.vm.hostname = "ucp-node3.local"
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
    ubuntu_dtr_node1.vm.box = "ubuntu/xenial64"
    ubuntu_dtr_node1.vm.network "private_network", ip: "172.28.128.34"
    ubuntu_dtr_node1.landrush.tld = 'local'
    ubuntu_dtr_node1.vm.hostname = "dtr-node1.local"
    ubuntu_dtr_node1.landrush.enabled = true
    ubuntu_dtr_node1.vm.provision "shell", inline: <<-SHELL
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
    ubuntu_worker_node1.vm.box = "ubuntu/xenial64"
    ubuntu_worker_node1.vm.network "private_network", ip: "172.28.128.35"
    ubuntu_worker_node1.landrush.tld = 'local'
    ubuntu_worker_node1.vm.hostname = "worker-node1.local"
    ubuntu_worker_node1.landrush.enabled = true
    ubuntu_worker_node1.vm.provision "shell", inline: <<-SHELL
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
    ubuntu_worker_node2.vm.box = "ubuntu/xenial64"
    ubuntu_worker_node2.vm.network "private_network", ip: "172.28.128.36"
    ubuntu_worker_node2.landrush.tld = 'local'
    ubuntu_worker_node2.vm.hostname = "worker-node2.local"
    ubuntu_worker_node2.landrush.enabled = true
    ubuntu_worker_node2.vm.provision "shell", inline: <<-SHELL
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
  config.vm.define "worker-node3" do |ubuntu_worker_node3|
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1500"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
      vb.name = "ubuntu-worker-node3"
    end
    ubuntu_worker_node3.vm.box = "ubuntu/xenial64"
    ubuntu_worker_node3.vm.network "private_network", ip: "172.28.128.39"
    ubuntu_worker_node3.landrush.tld = 'local'
    ubuntu_worker_node3.vm.hostname = "worker-node3.local"
    ubuntu_worker_node3.landrush.enabled = true
    ubuntu_worker_node3.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates ntpdate
      sudo ntpdate -s time.nist.gov
      sudo cp /vagrant/scripts/install_ee.sh .
      sudo cp /vagrant/scripts/join_worker.sh .
      sudo cp /vagrant/files/ucp_images_2.1.4.tar.gz .
      sudo chmod +x install_ee.sh
      sudo chmod +x join_worker.sh
      sleep 5
      # ./install_ee.sh
      # ./join_worker.sh
   SHELL
  end
end
