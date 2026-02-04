#!/usr/bin/env bash
set -euo pipefail

APP_NAME="myapp"
CLUSTER_NAME="devops"
IMAGE_LOCAL="${APP_NAME}:local"

# Load locally-built image into kind
kind load docker-image "$IMAGE_LOCAL" --name "$CLUSTER_NAME"

# Deploy with Helm
helm upgrade --install "$APP_NAME" ./helm/myapp \
  --set image.repository="$APP_NAME" \
  --set image.tag="local" \
  --set image.pullPolicy=IfNotPresent

kubectl rollout status deploy/$APP_NAME --timeout=120s
kubectl get pods -l app.kubernetes.io/name=$APP_NAME
