#!/bin/bash
set -x
export UCP_VERSION=2.2.4

ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' > /vagrant/ucp-node1-ipaddr
export UCP_IPADDR=$(cat /vagrant/ucp-node1-ipaddr)
export UCP_PASSWORD=$(cat /vagrant/ucp_password)
# docker load < ./ucp_images_2.1.4.tar.gz
docker swarm init --advertise-addr eth1
docker run --rm --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp:${UCP_VERSION} install --host-address ${UCP_IPADDR} --admin-password ${UCP_PASSWORD} --san ucp.landrush --license $(cat /vagrant/docker_subscription.lic)
docker run --rm --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp:${UCP_VERSION} id | awk '{ print $1}' > /vagrant/ucp-id
export UCP_ID=$(cat /vagrant/ucp-id)
