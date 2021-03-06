#!/usr/bin/env bash

source ${BASH_SOURCE%/*}/variables.sh

echo -e "\n\n### Setting up Consul Server ###\n\n"

yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

yum install -y consul

cp ${BASH_SOURCE%/*}/../config/consul/server.hcl /etc/consul.d/consul.hcl

# Enable systemd
echo "Enabling and starting Consul Server"
systemctl enable --now consul

echo "Done setting up Consul Server"

