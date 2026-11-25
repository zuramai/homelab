#!/usr/bin/env bash
# Manage the GitOps side of the homelab (k8s/).
#
# Usage: scripts/k8s.sh <command>
#   bootstrap   register the repo with Argo CD and apply the ApplicationSet
#   status      show Argo CD applications and their sync/health state
#   refresh     force Argo CD to re-read the git repo (hard refresh all apps)
#   secrets     one-shot: create namespaces + cluster secrets (k8s-secrets.sh)
#
# Bootstrap order on a fresh cluster:
#   1. install Argo CD + external-secrets (see k8s/README or the guide)
#   2. scripts/k8s.sh secrets      # generates passwords, saves secrets/k8s-bootstrap.env
#   3. scripts/k8s.sh bootstrap    # needs secrets/argocd-repo-secret.yaml (see example)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_SECRET="$ROOT/secrets/argocd-repo-secret.yaml"

usage() { sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

cmd="${1:-}"
case "$cmd" in
  bootstrap)
    if [ ! -f "$REPO_SECRET" ]; then
      echo "missing $REPO_SECRET" >&2
      echo "copy k8s/bootstrap/repo-secret.example.yaml there and fill in a read-only PAT" >&2
      exit 1
    fi
    kubectl apply -f "$REPO_SECRET"
    kubectl apply -f "$ROOT/k8s/bootstrap/apps.yaml"
    echo "==> applications will appear shortly; check: scripts/k8s.sh status"
    ;;
  status)
    kubectl get applications -n argocd \
      -o custom-columns='NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status,REVISION:.status.sync.revision'
    ;;
  refresh)
    for app in $(kubectl get applications -n argocd -o name); do
      kubectl annotate -n argocd "$app" argocd.argoproj.io/refresh=hard --overwrite
    done
    ;;
  secrets)
    exec "$ROOT/scripts/k8s-secrets.sh"
    ;;
  -h|--help|help|"") usage ;;
  *) echo "unknown command: $cmd" >&2; usage 1 ;;
esac