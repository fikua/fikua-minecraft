# fikua-minecraft

Private vanilla Minecraft (Java Edition) server for a handful of players,
running on the Fikua VPS. The server is containerized; players use the
regular Minecraft Launcher.

## What lives where

| Where | What |
| --- | --- |
| `Dockerfile` (public) | Base image pinned by digest, Minecraft `VERSION`, non-sensitive server settings |
| `compose.yaml` (public) | Runtime shape: limits, backup sidecar, port binding |
| Repo secrets | Who may join, RCON password, the address the port binds to |
| `fikua-platform-iac` (private) | Source of truth for `compose.yaml`, host setup (WireGuard, Docker ordering) |

This repo and its Actions logs are public. Nothing private is committed
or printed: private values are repo secrets, which GitHub masks in logs.

## Access model

- The game port is published only on the VPS's WireGuard address, never
  on the public interface. Players connect through their own WireGuard
  peer (one key per device).
- On top of that: online mode (real Mojang accounts) and an enforced
  whitelist.

## Workflows

- **`build.yml`** — on push to `main` touching the `Dockerfile` (or by
  hand): builds and pushes `docker.io/fikua/minecraft-server` as
  `latest` and `sha-<short>`. Never deploys.
- **`deploy.yml`** — by hand only (*Actions → Deploy Minecraft to VPS →
  Run workflow*). Copies `compose.yaml`, writes the host `.env` from
  secrets, restarts, waits for healthy and fails if port 25565 is bound
  anywhere but the VPN address.

Repo secrets (*Settings → Secrets and variables → Actions*):

| Secret | Value |
| --- | --- |
| `MINECRAFT_PLAYERS` | comma-separated Minecraft Java usernames |
| `MINECRAFT_RCON_PASSWORD` | `openssl rand -hex 24` |
| `MINECRAFT_BIND_IP` | the VPS's WireGuard address |

SSH and Docker Hub use the org secrets (`VPS_SSH_PRIVATE_KEY`,
`CF_ACCESS_CLIENT_*`, `DOCKER_*`), which the GitHub Free plan only
exposes to public repos.

## Upgrading Minecraft

1. On the host: `sudo docker exec minecraft-backup backup now`
2. Bump `VERSION` in the `Dockerfile` (PR → merge → `build.yml` runs).
3. Run `deploy.yml`.
4. Move every launcher to the same version.

Never lower `VERSION`: a world saved by a newer version does not open on
an older one. Restore from a backup instead.

Base image bumps arrive as Dependabot PRs (digest-pinned).

## On the VPS

```bash
ssh vps.fikua.com
cd /opt/vps/projects/minecraft
sudo docker compose ps
sudo docker compose logs -f minecraft
sudo docker exec -i minecraft rcon-cli          # server console
sudo docker exec minecraft-backup backup now    # manual archive
```

World: named volume `minecraft-data`. Archives:
`/opt/vps/backups/minecraft/` (daily, 7 days, local only for now).
