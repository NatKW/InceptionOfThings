#!/bin/bash

MASTER_IP="$1"

sudo systemctl disable ufw --now || true
sudo apt update -y
sudo apt install -y curl net-tools

# Installation de K3s en mode controller
export INSTALL_K3S_EXEC="--node-ip=$MASTER_IP --flannel-iface=eth1 --tls-san $MASTER_IP --bind-address=$MASTER_IP --advertise-address=$MASTER_IP --write-kubeconfig-mode 644"
curl -sfL https://get.k3s.io | sh -

echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh

sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token

# kubeconfig pour utilisation depuis l'hôte
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig.yaml
sudo sed -i "s/127.0.0.1/$MASTER_IP/g" /vagrant/kubeconfig.yaml
