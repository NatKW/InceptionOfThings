#!/bin/bash

MASTER_IP="$1"
WORKER_IP="$2"

sleep 10  # s'assurer que le token est bien présent
sudo apt update -y
sudo apt install -y curl net-tools

# Installation de K3s en tant que worker
export INSTALL_K3S_EXEC="--node-ip=$WORKER_IP --flannel-iface=eth1" 
export K3S_URL="https://$MASTER_IP:6443"
export K3S_TOKEN_FILE="/vagrant/node-token"
curl -sfL https://get.k3s.io | sh -

# Alias kubectl (au cas où pour debug)
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh