#!/bin/bash

# IP de la VM master (à adapter si besoin)
IP="192.168.56.110"

# Liste des hôtes à tester
HOSTS=("app1.com" "app2.com" "app3.com")

echo " Test de connectivité vers les apps via Ingress NGINX"

for HOST in "${HOSTS[@]}"; do
  echo -e "\n Test de $HOST:"
  curl -s -H "Host: $HOST" http://$IP | head -n 5
done

echo -e "\n Tests terminés."