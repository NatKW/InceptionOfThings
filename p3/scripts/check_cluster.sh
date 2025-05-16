#!/bin/bash

echo "[INFO] Vérification du cluster..."
kubectl cluster-info || exit 1
kubectl get nodes
kubectl get pods -Acd 
