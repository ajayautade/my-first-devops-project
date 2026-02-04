#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="devops"

if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "kind cluster '$CLUSTER_NAME' does not exist"
  exit 0
fi

kind delete cluster --name "$CLUSTER_NAME"
