#!/bin/bash

echo "[INFO] Création du cluster K3d..."
k3d cluster create iot-cluster --api-port 6550 -p "8080:80@loadbalancer"
