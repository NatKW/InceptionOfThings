#!/bin/bash

set -e

echo " Déploiement des applications web dans K3s"

# Appliquer les fichiers YAML des apps
kubectl apply -f /vagrant/confs/app1-deployment.yaml
kubectl apply -f /vagrant/confs/app2-deployment.yaml
kubectl apply -f /vagrant/confs/app3-deployment.yaml

# Appliquer l'ingress
kubectl apply -f /vagrant/confs/ingress.yaml

echo " Déploiement terminé."

echo -e "\n État des pods :"
kubectl get pods

echo -e "\n État des services :"
kubectl get svc

echo -e "\n État des Ingress :"
kubectl get ingress


