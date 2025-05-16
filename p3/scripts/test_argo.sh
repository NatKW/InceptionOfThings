#!/bin/bash

APP_NAME="iot-webapps"

echo "[INFO] Vérification de l'application ArgoCD : $APP_NAME"
argocd app get $APP_NAME || exit 1

echo "[INFO] État attendu : Synced / Healthy"
argocd app list | grep $APP_NAME
