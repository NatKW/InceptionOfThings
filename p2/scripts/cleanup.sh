#!/bin/bash

echo "Destruction des VMs Vagrant et nettoyage"

# 1. Détruire les machines
vagrant destroy -f

# 2. Supprimer le dossier de configuration local
rm -r ../.vagrant

# 3. Supprimer les fichiers partagés
rm -f p1 /node-token
rm -f p1 /kubeconfig.yaml

# 4. Supprimer les interfaces réseau VirtualBox host-only inutilisées
VBoxManage list hostonlyifs | grep -E 'Name:|IPAddress:' | awk 'NR%2{printf "%s ", $2; next} {print $2}' | while read -r name ip; do
    if [[ "$name" == *"vboxnet"* ]]; then
        VBoxManage hostonlyremove "$name"
    fi
done

echo "Environnement Vagrant nettoyé !"
