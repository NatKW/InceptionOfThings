
#environnement Linux (WSL2)

echo "=== Vérification du cluster K3d/K3s ==="

# Vérifier les conteneurs Docker du cluster
echo -e "\n[1/5] Conteneurs Docker K3d :"
docker ps --filter "name=k3d-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Vérifier les infos du cluster
echo -e "\n[2/5] Infos cluster Kubernetes :"
kubectl cluster-info || echo " Impossible de récupérer les infos du cluster."

# Vérifier les nœuds
echo -e "\n[3/5] Nœuds Kubernetes :"
kubectl get nodes -o wide || echo " Aucun nœud détecté."

# Vérifier les pods système
echo -e "\n[4/5] Pods système (kube-system) :"
kubectl get pods -n kube-system || echo " Aucun pod kube-system trouvé."

# Vérifier ArgoCD si installé
echo -e "\n[5/5] Vérification ArgoCD (si installé) :"
kubectl get pods -n argocd 2>/dev/null || echo "  ArgoCD non trouvé "

echo -e "\n Vérification terminée."