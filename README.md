# homelab

My homelab: Docker Compose services on the host, Kubernetes apps managed by
Argo CD, and the scripts to run them. Structure inspired by
[ccrsxx/homelab](https://github.com/ccrsxx/homelab).

```
docker/            Docker Compose apps (one directory per app)
  affine/          AFFiNE notes        (notes.saugi.me)
  cloudflared/     Cloudflare tunnel
  infisical/       Infisical secrets manager
  navidrome/       music server
  vaultwarden/     password manager
k8s/
  apps/            GitOps manifests, one Application per directory
    databases/     postgres + mongo (StatefulSets, tailnet exposure)
    headlamp/      Headlamp UI (tailnet only)
    nulis/         nulis.saugi.me
    siti/          telegram bot
    cloudflared/   in-cluster tunnel connector
  bootstrap/       Argo CD ApplicationSet + repo-secret template
scripts/           docker.sh, k8s.sh, k8s-secrets.sh
secrets/           host-only credentials (gitignored, never committed)
renovate.json      image update automation
```

## Docker

Each app is a plain `docker compose` project; `./data` and `.env` live next to
the compose file and are gitignored.

```bash
scripts/docker.sh list                 # available apps
scripts/docker.sh up                   # start everything
scripts/docker.sh up infisical         # start one app
scripts/docker.sh update vaultwarden   # pull + recreate
scripts/docker.sh logs cloudflared
scripts/docker.sh down                 # stop everything (data kept)
```

First run on a new host: copy `docker/*/.env.example` to `.env` and fill in
real values. `cloudflared` and `navidrome` share the external `tunnel`
network; `docker.sh up` creates it if missing.

## Kubernetes (GitOps)

`k8s/apps/*` is reconciled by Argo CD via the ApplicationSet in
`k8s/bootstrap/apps.yaml` (auto-sync, prune, self-heal). App secrets come from
Infisical through external-secrets; nothing sensitive is stored in git.

```bash
scripts/k8s.sh secrets      # one-shot: namespaces + generated cluster secrets
scripts/k8s.sh bootstrap    # register repo PAT + apply the ApplicationSet
scripts/k8s.sh status       # sync/health of all applications
scripts/k8s.sh refresh      # force a hard refresh from git
```

Bootstrap needs `secrets/argocd-repo-secret.yaml` — copy
`k8s/bootstrap/repo-secret.example.yaml` and fill in a read-only PAT.

### Headlamp

Headlamp is exposed on the tailnet only, at
`http://headlamp.starling-tilapia.ts.net` (no public Cloudflare hostname).
Its ServiceAccount is bound to `cluster-admin`; log in with a bearer token.
A usable token is stored host-side in `secrets/headlamp-token` (gitignored).
Regenerate it with:

```bash
kubectl -n headlamp create token headlamp --duration=8760h
```

## Secrets policy

Never committed: `secrets/` (PATs, generated passwords), `docker/*/data/`,
`docker/*/.env`, `docker/affine/config/private.key`. Committed counterparts
are `*.example` templates with empty placeholders. If a credential ever lands
in a commit, rotate it — removing the file is not enough.