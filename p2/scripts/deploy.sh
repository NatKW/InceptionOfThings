#!/bin/bash

set -e

echo " Vérification du cluster Kubernetes..."

# Vérifier que le nœud est Ready
if ! kubectl get nodes | grep -q " Ready"; then
  echo " Le nœud n'est pas prêt. Annulation du déploiement."
  exit 1
fi

# Vérifier que le Ingress Controller est prêt
echo "Vérification du Ingress NGINX..."
if ! kubectl get pods -n ingress-nginx | grep -q " Running"; then
  echo " Le contrôleur Ingress NGINX n'est pas en cours d'exécution. Annulation du déploiement."
  exit 1
fi

echo " Cluster prêt. Déploiement des applications web dans K3s..."

# Déploiement des apps
kubectl apply -f /vagrant/confs/app1-deployment.yaml
kubectl create configmap app2-html --from-file=/vagrant/confs/app2/index.html --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f /vagrant/confs/app3-deployment.yaml

# Appliquer l'ingress
kubectl apply -f /vagrant/confs/ingress.yaml

echo " Déploiement terminé."

echo -e "\\n État des pods :"
kubectl get pods

echo -e "\\n État des nodes :"
kubectl get nodes

echo -e "\\n État des services :"
kubectl get svc

echo -e "\\n État des Ingress :"
kubectl get ingress
