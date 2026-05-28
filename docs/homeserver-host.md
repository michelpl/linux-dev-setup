# Homeserver host bootstrap

This document describes how to prepare an Ubuntu host for the **homeserver** project. It does **not** cover OS installation.

## Prerequisites

- Ubuntu 24.04+ (26.04 supported)
- User with `sudo`
- Network access (LAN + internet)
- SSH public key in `~/.ssh/authorized_keys` before running `openssh-hardening` on a remote host

## Step 1: Bootstrap tooling

```bash
curl -fsSL https://raw.githubusercontent.com/michelpl/linux-dev-setup/main/script.sh | bash
```

This installs `git`, authenticates `gh`, and clones this repo to `~/projects/linux-dev-setup`.

## Step 2: Homeserver host preset

```bash
cd ~/projects/linux-dev-setup/Ubuntu
./setup.sh i homeserver-host
```

Or install components individually: `docker`, `openssh-hardening`, `ufw`, `fail2ban`, `unattended-upgrades`, `homeserver-power`.

Log out and back in after Docker installs if your user was added to the `docker` group.

## Step 3: Homeserver application stack

```bash
gh repo clone michelpl/homeserver ~/projects/homeserver
cd ~/projects/homeserver
make init-local
# Edit .env (set TS_AUTHKEY from Tailscale admin)
make deploy
make install-systemd
```

Application updates are delivered by **GitHub Actions** (rsync + deploy over SSH), not by git pull or cron on the server. See the homeserver [deploy.md](https://github.com/michelpl/homeserver/blob/main/docs/deploy.md).

## What stays out of this repo

- Tailscale (Docker container in homeserver)
- Docker Compose application stacks
- Application secrets (`.env` in homeserver, gitignored)

## Re-running safely

All scripts are idempotent. Re-run `./setup.sh i homeserver-host` after pulling updates to this repository.
