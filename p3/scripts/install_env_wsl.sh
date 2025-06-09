#terminal wsl2 - Ubuntu (environnement Linux)

echo "[1/6] Mise à jour du système"
sudo apt update && sudo apt upgrade -y

echo "[2/6] Installation de curl, ca-certificates et apt-transport-https"
sudo apt install -y curl ca-certificates apt-transport-https gnupg lsb-release

echo "[3/6] Installation de Docker"
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
echo "Se déconnecter et se reconnecter  à sa session pour activer l'accès Docker sans sudo "

echo "[4/6] Installation de kubectl (version stable)"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" |   sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl

echo "[5/6] Installation de k3d (via script officiel)"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "[6/6] Vérification des versions installées"
docker --version
kubectl version --client
k3d version

echo " Installation terminée !"
