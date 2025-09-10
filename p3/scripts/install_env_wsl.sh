
#environnement Linux (WSL2)

echo "[1/6] Mise à jour du système"
sudo apt update && sudo apt upgrade -y

echo "[2/6] Installation de curl, ca-certificates et apt-transport-https"
sudo apt install -y curl ca-certificates apt-transport-https gnupg lsb-release

echo "[3/6] Installation de Docker (via Docker officiel)"
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker CLI (pas de daemon dans WSL)
sudo apt update
sudo apt install -y docker-ce-cli

sudo usermod -aG docker $USER

echo "⚠️ L'intégration WSL doit être activée et Docker Desktop installé sur Windows"
echo "Se reconnecter à sa session pour utiliser Docker sans sudo"

echo "[4/6] Installation de kubectl (version stable)"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | 
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl

echo "[5/6] Installation de k3d (via script officiel)"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "[6/6] Vérification des versions installées"
docker --version
kubectl version --client
k3d version

echo " Installation terminée !"
