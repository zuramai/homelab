#!/usr/bin/env bash
# Manage the Docker Compose apps under docker/.
#
# Usage: scripts/docker.sh <command> [app ...]
#   up        create/start containers (detached)
#   update    pull newer images, then recreate
#   down      stop and remove containers (data volumes are kept)
#   restart   restart containers
#   logs      tail the last 100 log lines
#   ps        show container status
#   list      list available apps
#
# With no app names the command runs against every app in docker/.
# Examples:
#   scripts/docker.sh up                  # start everything
#   scripts/docker.sh update vaultwarden  # update one app
#   scripts/docker.sh logs infisical
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_DIR="$ROOT/docker"

usage() { sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

all_apps() {
  local d
  for d in "$DOCKER_DIR"/*/; do
    [ -f "$d/compose.yaml" ] && basename "$d"
  done
}

cmd="${1:-}"
[ -n "$cmd" ] || usage 1
shift || true

case "$cmd" in
  list) all_apps; exit 0 ;;
  up|update|down|restart|logs|ps) ;;
  -h|--help|help) usage ;;
  *) echo "unknown command: $cmd" >&2; usage 1 ;;
esac

if [ "$#" -gt 0 ]; then
  apps=("$@")
else
  mapfile -t apps < <(all_apps)
fi

for app in "${apps[@]}"; do
  dir="$DOCKER_DIR/$app"
  if [ ! -f "$dir/compose.yaml" ]; then
    echo "no such app: $app (see: scripts/docker.sh list)" >&2
    exit 1
  fi
done

# cloudflared and navidrome attach to the shared external 'tunnel' network.
if [ "$cmd" = up ] || [ "$cmd" = update ]; then
  docker network inspect tunnel >/dev/null 2>&1 || docker network create tunnel >/dev/null
fi

for app in "${apps[@]}"; do
  echo "==> $app"
  (
    cd "$DOCKER_DIR/$app"
    case "$cmd" in
      up)      docker compose up -d ;;
      update)  docker compose pull && docker compose up -d ;;
      down)    docker compose down ;;
      restart) docker compose restart ;;
      logs)    docker compose logs --tail=100 ;;
      ps)      docker compose ps ;;
    esac
  )
done