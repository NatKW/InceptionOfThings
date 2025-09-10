#environnement Linux (WSL2)

echo "Suppression du cluster K3d 'iot-cluster'..."
k3d cluster delete iot-cluster

echo "Suppression des namespaces 'argocd' et 'dev' (si restés actifs)..."
kubectl delete ns argocd --ignore-not-found
kubectl delete ns dev --ignore-not-found

echo " Tentative d'arrêt des port-forwards éventuels..."
# Kill any port-forward to argocd-server
lsof -i :8081 | grep LISTEN | awk '{print $2}' | xargs -r kill -9 || true

echo "Cluster supprimé avec succès."
