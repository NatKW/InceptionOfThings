#!/bin/bash
set -e
#pour wsl avec Docker natif
export DOCKER_HOST=unix:///var/run/docker.sock

echo "[1/7] Création du cluster K3d..."
k3d cluster create iot-cluster --api-port 6550 -p "8080:80@loadbalancer"

echo "[2/7] Création des namespaces 'argocd' et 'dev'..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

echo "[3/7] Installation de Argo CD dans le namespace 'argocd'..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[4/7] Attente des pods Argo CD ..."
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd

echo "[5/7] Exposition temporaire de l'interface web Argo CD sur le port 8081"
kubectl port-forward svc/argocd-server -n argocd 8081:443 &

echo "[6/7] Création du fichier Application pour Argo CD..."
cat <<EOF | kubectl apply -n argocd -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: iot-webapps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/NatKW/InceptionOfThings.git
    targetRevision: main
    path: p3/manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

echo "[7/7] Déploiement terminé. Vérifiez dans Argo CD : http://localhost:8081"

echo "Mot de passe Argo CD pour l'utilisateur 'admin' :"
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
