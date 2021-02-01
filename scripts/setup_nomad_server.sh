#!/usr/bin/env bash

source ${BASH_SOURCE%/*}/variables.sh

echo -e "\n\n### Setting up Nomad Server ###\n\n"

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

sudo yum install -y nomad
sudo cp ${BASH_SOURCE%/*}/../config/nomad/server.hcl /etc/nomad.d/nomad.hcl

# Enable systemd
echo "Enabling and starting Nomad"
sudo systemctl enable --now nomad

echo "Done setting up Nomad server"