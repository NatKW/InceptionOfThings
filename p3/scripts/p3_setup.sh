
#environnement Linux (WSL2)

#  Création du cluster K3d
echo "[1/8] Création du cluster K3d..."
if k3d cluster list | grep -q iot-cluster; then
    echo "⚠️ Le cluster 'iot-cluster' existe déjà. Suppression avant création..."
    k3d cluster delete iot-cluster
fi
k3d cluster create iot-cluster --api-port 6550 -p "8080:80@loadbalancer"

#  Création des namespaces
echo "[2/8] Création des namespaces 'argocd' et 'dev'..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

#  Installation d'Argo CD
echo "[3/8] Installation de Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#  Attente des pods Argo CD
echo "[4/8] Attente des pods Argo CD..."
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd

#  Installation Ingress public pour Argo CD
echo "[5/8] Déploiement Ingress public pour Argo CD..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
    - host: argocd.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 443
EOF

#  Installation NGINX Ingress Controller
echo "[6/8] Installation NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml
echo "Attente du Ingress Controller NGINX..."
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s

#  Création Application Argo CD
echo "[7/8] Création du fichier Application pour Argo CD..."
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

#  Informations Argo CD + port-forward automatique
echo "[8/8] Déploiement terminé."

# Définir le port pour le port-forward
TARGET_PORT=8081
while lsof -i TCP:$TARGET_PORT >/dev/null 2>&1; do
    echo "⚠️ Port $TARGET_PORT occupé, test du port suivant..."
    TARGET_PORT=$((TARGET_PORT+1))
done

echo "Port-forward Argo CD sur localhost:$TARGET_PORT..."
kubectl port-forward svc/argocd-server -n argocd $TARGET_PORT:443 &

echo "Interface Argo CD : https://localhost:$TARGET_PORT"
echo "Mot de passe Argo CD pour l'utilisateur 'admin' :"
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo

echo "Docker Desktop doit rester actif pendant l'utilisation du cluster."