#pour wsl avec Docker natif
export DOCKER_HOST=unix:///var/run/docker.sock

echo " Vérification des prérequis..."
for cmd in curl docker kubectl; do
  if ! command -v $cmd &> /dev/null; then
    echo " $cmd non trouvé : prérequis à installer avant de continuer"
    exit 1
  fi
done
echo " Tous les outils nécessaires sont présents."

echo "[1/8] Création du cluster K3d..."
k3d cluster create iot-cluster --api-port 6550 -p "8080:80@loadbalancer"

echo "[2/8] Création des namespaces 'argocd' et 'dev'..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

echo "[3/8] Installation de Argo CD dans le namespace 'argocd'..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[4/8] Attente des pods Argo CD ..."
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd

echo "[5/8] Déploiement d’un Ingress public pour Argo CD via NGINX..."
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

echo "[6/8] Installation de NGINX Ingress Controller (via manifests officiels)..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml

echo " Attente du Ingress Controller NGINX ..."
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s

echo "[7/8] 🧾 Création du fichier Application pour Argo CD..."
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

echo "[8/8] Déploiement terminé. Interface Argo CD : http://localhost:8080"

echo " Mot de passe Argo CD pour l'utilisateur 'admin' :"
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
