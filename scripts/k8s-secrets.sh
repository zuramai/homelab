#!/usr/bin/env bash
# Guide section 11.4 — create the one-shot cluster secrets.
# GHCR packages are public, so no imagePullSecret/ghcr secret is created.
# Run once after Argo CD bootstrap. Values needed later are saved to secrets/k8s-bootstrap.env.
set -euo pipefail

for ns in databases nulis siti cloudflared; do
  if kubectl get namespace "$ns" >/dev/null 2>&1; then
    echo "namespace $ns already exists — 11.4 already ran; refusing to regenerate passwords" >&2
    exit 1
  fi
done

read -r  -p 'Infisical client ID (homelab-k8s): ' INFISICAL_CLIENT_ID
read -r -s -p 'Infisical client secret: ' INFISICAL_CLIENT_SECRET
echo

CF_TOKEN="$(docker inspect cloudflared --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | sed -n 's/^TUNNEL_TOKEN=//p')"
if [ -z "${CF_TOKEN:-}" ]; then
  read -r -s -p 'Cloudflare tunnel token: ' CF_TOKEN
  echo
fi
[ -n "$CF_TOKEN" ] || { echo 'missing tunnel token' >&2; exit 1; }

umask 077
OUT="$HOME/homelab/secrets/k8s-bootstrap.env"
mkdir -p "$(dirname "$OUT")"

PG_ADMIN_PW="$(openssl rand -hex 24)"
MONGO_ROOT_PW="$(openssl rand -hex 24)"
NULIS_DB_PW="$(openssl rand -hex 16)"
SITI_DB_PW="$(openssl rand -hex 16)"
NUXT_SESSION_PASSWORD="$(openssl rand -hex 24)"
NUXT_ENCRYPTION_KEY="$(openssl rand -hex 24)"
NUXT_MONGODB_URI="mongodb://nulis:${NULIS_DB_PW}@mongo.databases.svc.cluster.local:27017/nulis"
DATABASE_URL="postgres://siti:${SITI_DB_PW}@postgres.databases.svc.cluster.local:5432/siti"

# Save before creating anything: a failure halfway must not lose these.
{
  printf 'PG_ADMIN_PW=%q\n'              "$PG_ADMIN_PW"
  printf 'MONGO_ROOT_PW=%q\n'            "$MONGO_ROOT_PW"
  printf 'NULIS_DB_PW=%q\n'              "$NULIS_DB_PW"
  printf 'SITI_DB_PW=%q\n'               "$SITI_DB_PW"
  printf 'NUXT_MONGODB_URI=%q\n'         "$NUXT_MONGODB_URI"
  printf 'NUXT_SESSION_PASSWORD=%q\n'    "$NUXT_SESSION_PASSWORD"
  printf 'NUXT_ENCRYPTION_KEY=%q\n'      "$NUXT_ENCRYPTION_KEY"
  printf 'DATABASE_URL=%q\n'             "$DATABASE_URL"
} > "$OUT"
chmod 600 "$OUT"

for ns in databases nulis siti cloudflared; do kubectl create namespace "$ns"; done

kubectl -n databases create secret generic postgres-admin --from-literal=password="$PG_ADMIN_PW"
kubectl -n databases create secret generic mongo-admin    --from-literal=password="$MONGO_ROOT_PW"

for ns in nulis siti; do
  kubectl -n "$ns" create secret generic infisical-auth \
    --from-literal=clientId="$INFISICAL_CLIENT_ID" \
    --from-literal=clientSecret="$INFISICAL_CLIENT_SECRET"
done

kubectl -n cloudflared create secret generic cloudflared-token --from-literal=token="$CF_TOKEN"

echo
echo "saved values: $OUT (0600)"
echo "Infisical prod env: nulis <- NUXT_MONGODB_URI, NUXT_SESSION_PASSWORD, NUXT_ENCRYPTION_KEY"
echo "                    siti  <- DATABASE_URL"
echo "before 11.5:        source $OUT"
