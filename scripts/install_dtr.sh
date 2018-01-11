#!/bin/bash
set -x
DTR_VERSION=2.4.1

< /dev/urandom tr -dc a-f0-9 | head -c${1:-12} > /vagrant/dtr-replica-id
ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' > /vagrant/dtr-node1-ipaddr

UCP_IPADDR=$(cat /vagrant/ucp-node1-ipaddr)
UCP_PASSWORD=$(cat /vagrant/ucp_password)
DTR_REPLICA_ID=$(cat /vagrant/dtr-replica-id)

curl -Ssk https://${UCP_IPADDR}/ca > /home/vagrant/ucp-ca.pem

# Sleep 35 seconds to wait for node registration
sleep 35

# docker load < ./dtr-2.2.5.tar.gz
# Install DTR
docker pull docker/dtr:${DTR_VERSION}
docker run --rm docker/dtr:${DTR_VERSION} install --ucp-url https://"${UCP_IPADDR}" --ucp-node dtr-node1 --dtr-external-url https://dtr.landrush --ucp-username admin --ucp-password "${UCP_PASSWORD}" --ucp-insecure-tls

# Trust self-signed DTR CA
curl -Ssk https://localhost/ca -o /usr/local/share/ca-certificates/dtr.landrush.crt
update-ca-certificates
systemctl restart docker
