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
    immich/        photo + video library (T7 SSD, tailnet only)
    nulis/         nulis.saugi.me
    opencloud/     file archive (T7 SSD, tailnet only)
    siti/          telegram bot
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
network; `docker.sh up` creates it if missing. The Docker `cloudflared` is the
only tunnel connector: it reaches compose apps by service name and k8s
hostnames through Traefik on the host IP.

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

### Immich

Photos and videos at `https://immich.starling-tilapia.ts.net` — tailnet only,
certificate issued by the Tailscale operator (`ingressClassName: tailscale`).
No public Cloudflare hostname.

The library lives on the external Samsung PSSD T7, ext4, mounted from
`/etc/fstab` at `/srv/t7` (`nofail`) with media in `/srv/t7/immich/media` and the
ML model cache in `/srv/t7/immich/ml-cache`. PostgreSQL is the one piece that
stays on the NVMe: Immich's image initialises `PGDATA` with `--data-checksums`
and 0700 permissions, so it wants a local journaled filesystem rather than the
shared data disk.

The SSD paths are `hostPath` PVs of type `Directory`, so an unplugged disk fails
the pod instead of starting an empty library on the boot disk, and the server's
`require-ssd` initContainer refuses to start unless `/data` is ext4 (the root
filesystem is btrfs).

The DB password is generated into `secrets/k8s-bootstrap.env` (`IMMICH_DB_PW`)
and seeded as the `immich-db` Secret; nothing is committed.

### OpenCloud

File archive at `https://cloud.starling-tilapia.ts.net` — tailnet only. One
upstream container (`opencloudeu/opencloud-rolling`) with the built-in IDM; the
community Helm charts are archived and unsupported, so these manifests are
hand-written like the rest of `k8s/apps`.

Its posix storage driver needs extended attributes, which is one of the reasons
the T7 is ext4. The dataset lives in `/srv/t7/opencloud/{data,config}` on
`hostPath` PVs of type `Directory`. Admin user is `admin`; the password is
`OPENCLOUD_ADMIN_PW` in `secrets/k8s-bootstrap.env`. WebDAV basic auth is
enabled, so `rclone`/`curl` can upload without the browser OIDC flow.

### The T7 disk

`/srv/t7` is the external Samsung PSSD T7 (931 GB), and it holds every byte of
both apps' payload:

| Path | Contents |
| --- | --- |
| `/srv/t7/immich/media` | Immich originals, thumbs, encoded video, DB dumps |
| `/srv/t7/immich/ml-cache` | ML models (~2 GB) |
| `/srv/t7/opencloud/data` | OpenCloud decomposedfs dataset + IDM state |
| `/srv/t7/opencloud/config` | generated `opencloud init` config |

It was exFAT until 2026-11-26; ext4 gives journaling, POSIX ownership,
case-sensitivity and xattrs. No TRIM reaches the disk over this USB bridge, so
the enclosure's own garbage collection does the work — nothing to schedule.

## Secrets policy

Never committed: `secrets/` (PATs, generated passwords), `docker/*/data/`,
`docker/*/.env`, `docker/affine/config/private.key`. Committed counterparts
are `*.example` templates with empty placeholders. If a credential ever lands
in a commit, rotate it — removing the file is not enough.