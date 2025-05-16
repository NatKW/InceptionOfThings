#!/bin/bash
# Applique tous les fichiers YAML contenus dans ./manifests dans le namespace apps

echo "[INFO] Création du namespace apps (si besoin)..."
kubectl create namespace apps --dry-run=client -o yaml | kubectl apply -f -

echo "[INFO] Déploiement des applications..."
kubectl apply -n apps -f manifests/

echo "[INFO] État des pods après déploiement :"
kubectl get pods -n apps
