# -*- mode: ruby -*-
# vi: set ft=ruby :
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'
# EE Subscription
ee_sub_url = File.open("ee_sub_id")
EE_SUBSCRIPTION_ID = ee_sub_url.read.chomp

if !EE_SUBSCRIPTION_ID && (ARGV.include?("up") || (ARGV.include?("provision")))
  puts "Please set the environment variable 'EE_SUBSCRIPTION_ID' with a valid Docker EE subscription"
  exit
end

Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"

  ### Environment Settings
  config.vm.provider :libvirt do |l|
    # l.username = "vagrant"
    # l.password = 'vagrant'
    # l.connect_via_ssh = true
    l.driver = "kvm"
    l.uri = 'qemu+unix:///system'
    # l.id_ssh_key_file = "/home/ada/.ssh/vagrant"
    l.storage_pool_name = "default"
  end
  config.vm.provider :virtualbox do |v|
    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end

  # don't remove entries from /etc/hosts on suspend
  config.hostsupdater.remove_on_suspend = false
  config.landrush.guest_redirect_dns = false
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


  ### Virtual Machine definitions

  # Docker EE node for ubuntu 7.3
  config.vm.define "haproxy" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "1024"
      domain.cpus = 1
      domain.host = "haproxy"
    end
    node.vm.network "private_network", :ip => "172.28.2.30"
    node.vm.hostname = "haproxy.local.antiskub.net"
    node.hostsupdater.aliases = ["local.antiskub.net", "ucp.local.antiskub.net", "dtr.local.antiskub.net"]
    node.vm.provision "shell", inline: <<-SHELL
      yum install -y haproxy
      sed -i 's/enforcing/disabled/g' /etc/selinux/config
      setenforce 0
      sed -i '/module(load="imudp")/s/^#//g' /etc/rsyslog.conf
      sed -i '/input(type="imudp" port="514")/s/^#//g' /etc/rsyslog.conf
      service rsyslog restart
      cp /vagrant/files/haproxy.cfg /etc/haproxy/haproxy.cfg
      systemctl enable haproxy
      systemctl restart haproxy
    SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "12000"
      domain.cpus = 4
      domain.host = "ucp-1"
    end
    node.vm.network "private_network", ip: "172.28.2.31"
    node.vm.hostname = "ucp-1.local.antiskub.net"
    # node.vm.provision "shell", inline: <<-SHELL
    #   ntpdate -s time.nist.gov
    # SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-2" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "8192"
      domain.cpus = 2
      domain.host = "ucp-2"
    end
    node.vm.network "private_network", ip: "172.28.2.32"
    node.vm.hostname = "ucp-2.local.antiskub.net"
    node.landrush.enabled = true
    # node.vm.provision "shell", inline: <<-SHELL
    #   ntpdate -s time.nist.gov
    # SHELL
  end

  # Docker EE node for ubuntu 7.3
  config.vm.define "ucp-3" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "8192"
      domain.cpus = 2
      domain.host = "ucp-3"
    end
    node.vm.network "private_network", ip: "172.28.2.33"
    node.vm.hostname = "ucp-3.local.antiskub.net"
    node.landrush.enabled = true
    # node.vm.provision "shell", inline: <<-SHELL
    #   ntpdate -s time.nist.gov
    # SHELL
  end

  config.vm.define "dtr-1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "8192"
      domain.cpus = 2
      domain.host = "dtr-1"
    end
    node.vm.network "private_network", ip: "172.28.2.34"
    node.vm.hostname = "dtr-1.local.antiskub.net"
    # node.vm.provision "shell", inline: <<-SHELL
    #   ntpdate -s time.nist.gov
    # SHELL
  end

  config.vm.define "worker-1" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 1
      domain.host = "worker-1"
    end
    node.vm.network "private_network", ip: "172.28.2.35"
    node.vm.hostname = "worker-1.local.antiskub.net"
    # node.vm.provision "shell", inline: <<-SHELL
    #   ntpdate -s time.nist.gov
    # SHELL
    node.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/install.yml"
      ansible.limit = "swarm"
      ansible.raw_arguments = [
        "--inventory", "ansible/inventory/2.groups"
      ]
      ansible.verbose = "v"
      ansible.groups = {
        # DCI provisioned groups
        "linux-ucp-manager-primary" => ["ucp-1"],
        "linux-ucp-manager-replicas" => [],
        "linux-dtr-worker-primary" => ["dtr-1"],
        "linux-dtr-worker-replicas" => [],
        "linux-workers" => ["worker-1", "worker-2", "worker-3"],
        "windows-workers" => [],
        "ucp-load-balancer" => ["haproxy"],
        "dtr-load-balancer" => ["haproxy"],
        # my additional groups
        "system"       => ["ucp-1", "dtr-1"],
        "workers"        => ["worker-1","worker-2","worker-3"],
        "proxy"          => ["haproxy"],
        "swarm:children" => ["system","workers"]
      }
      ansible.extra_vars = {
        docker_ucp_lb: "ucp.local.antiskub.net",
        docker_dtr_lb: "dtr.local.antiskub.net",
        docker_ee_subscriptions_ubuntu: EE_SUBSCRIPTION_ID,
        docker_ee_subscriptions_centos: EE_SUBSCRIPTION_ID,
        docker_dtr_replica_id: "1234567890ab",
        docker_ucp_admin_password: "orca1234",
        docker_swarm_listen_address: "172.28.2.31",
        infra_stack: "vmware"  # not really vmware but required to skip irrelevant playbooks
      }
    end
  end

  config.vm.define "worker-2" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 1
      domain.host = "worker-2"
    end
    node.vm.network "private_network", ip: "172.28.2.36"
    node.vm.hostname = "worker-2.local.antiskub.net"
    # node.vm.provision "shell", inline: <<-SHELL
    #   ntpdate -s time.nist.gov
    # SHELL
  end

  config.vm.define "worker-3" do |node|
    node.vm.provider :libvirt do |domain|
      domain.memory = "2048"
      domain.cpus = 1
      domain.host = "worker-3"
    end
    node.vm.network "private_network", ip: "172.28.2.37"
    node.vm.hostname = "worker-3.local.antiskub.net"
    # node.vm.provision "shell", inline: <<-SHELL
    #   ntpdate -s time.nist.gov
    # SHELL
  end
end
