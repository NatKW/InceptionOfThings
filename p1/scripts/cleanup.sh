#!/bin/bash

echo "🔁 Destruction des VMs Vagrant et nettoyage..."

# 1. Détruire les machines
vagrant destroy -f

# 2. Supprimer le dossier de configuration local
rm -r ../.vagrant

# 3. Supprimer les fichiers partagés
rm -f p1 /node-token
rm -f p1/kubeconfig.yaml

# 4. Supprimer les interfaces VirtualBox host-only inutilisées
clean_net done

echo "Environnement Vagrant nettoyé !"
