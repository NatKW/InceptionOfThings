

#environnement Linux (WSL2)

# 1. Variables
LOCAL_REPO_PATH="$HOME/C:\Users\thnab\OneDrive\Documents\CODE\IoT_project\InceptionOfThings"
REPO_NAME="iot-local-repo"
ARGO_APP_NAME="iot-webapps"
GIT_PORT=9418   # Port standard pour git://
BRANCH="main"

# 2. Lancer le serveur Git local
echo "==> Lancement du serveur Git local sur $LOCAL_REPO_PATH..."
if ! pgrep -f "git daemon --reuseaddr" >/dev/null; then
    git daemon --reuseaddr --base-path=$LOCAL_REPO_PATH --export-all --verbose &
    echo "Serveur Git lancé sur git://localhost/$REPO_NAME"
else
    echo "⚠️ Serveur Git déjà en cours d'exécution."
fi

# 3. Vérifier si le dépôt existe
if [ ! -d "$LOCAL_REPO_PATH/.git" ]; then
    echo "⚠️ Pas de dépôt Git trouvé, initialisation..."
    cd $LOCAL_REPO_PATH
    git init
    git checkout -b $BRANCH
    git add .
    git commit -m "Initial commit"
else
    echo " Dépôt Git déjà initialisé."
fi

# 4. Modifier l'Application Argo CD pour utiliser le dépôt local
echo "==> Mise à jour de l'application Argo CD pour utiliser le dépôt local..."
cat <<EOF | kubectl apply -n argocd -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $ARGO_APP_NAME
  namespace: argocd
spec:
  project: default
  source:
    repoURL: git://localhost/$REPO_NAME
    targetRevision: $BRANCH
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

# 5. Info utilisateur
echo " Argo CD est maintenant configuré avec mon dépôt local Git"
echo "  URL dépôt : git://localhost/$REPO_NAME"
echo "  Chaque commit local sur '$BRANCH' déclenche une synchro Argo CD."
echo "  Pour arrêter le serveur Git : pkill -f 'git daemon --reuseaddr'"
