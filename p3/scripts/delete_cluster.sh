#!/bin/bash

echo "Suppression du cluster K3d 'iot-cluster'..."
k3d cluster delete iot-cluster

echo "Cluster supprimé avec succès."
