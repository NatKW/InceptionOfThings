#!/bin/bash

MASTER_IP="$1"

echo " Configuration du master node ($MASTER_IP)"

# Mise à jour & outils réseau
sudo apt update -y
sudo apt install -y curl net-tools

# Installation de K3s avec configuration complète + désactivation de Traefik
export INSTALL_K3S_EXEC="--node-ip=$MASTER_IP --flannel-iface=eth1 --tls-san $MASTER_IP --bind-address=$MASTER_IP --advertise-address=$MASTER_IP --write-kubeconfig-mode 644 --disable=traefik"
curl -sfL https://get.k3s.io | sh -

# Création d'un alias système pour kubectl
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh

# Copie du token pour les workers
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token

# Copie du fichier kubeconfig côté hôte
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig.yaml
sudo sed -i "s/127.0.0.1/$MASTER_IP/g" /vagrant/kubeconfig.yaml

# Configuration automatique de l’environnement utilisateur
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/vagrant/.bashrc
echo "alias k='kubectl'" >> /home/vagrant/.bashrc

# Installation d'Ingress NGINX
echo " Installation de l'Ingress Controller NGINX "
/usr/local/bin/kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml

