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

Or install components individually: `docker`, `tailscale`, `openssh-hardening`, `ufw`, `fail2ban`, `unattended-upgrades`, `homeserver-power`.

Log out and back in after Docker installs if your user was added to the `docker` group.

The `tailscale` app installs the Tailscale package and enables `tailscaled`. It does **not** run `tailscale up` — auth happens in the homeserver repo (`make ensure-tailscale`), which **must** enable Tailscale SSH (`--ssh`) so the host stays reachable after UFW/OpenSSH hardening.

### Always-on power (`homeserver-power`)

Included in `homeserver-host`. It:

- **Masks** `sleep.target`, `suspend.target`, `hibernate.target`, `hybrid-sleep.target` (OS cannot suspend)
- Writes logind drop-in `/etc/systemd/logind.conf.d/99-homeserver-power.conf` (ignore suspend/lid/idle; power button = poweroff)
- Applies system-wide GNOME dconf so Desktop idle does not suspend

A blank monitor is acceptable if Tailscale/SSH still work. That is display blanking, not OS sleep.

**BIOS/UEFI (once, manual):** disable Sleep / ErP / Deep S4 / “PCI Express power management” style options that cut power when “idle”. The OS cannot fully override firmware sleep.

Re-apply after pulling this repo:

```bash
cd ~/projects/linux-dev-setup/Ubuntu
./setup.sh i homeserver-power
```

Verify: `systemctl is-enabled suspend.target` prints `masked`.

## Step 3: Homeserver application stack

```bash
gh repo clone michelpl/homeserver ~/projects/homeserver
cd ~/projects/homeserver
./scripts/bootstrap-server.sh
```

The bootstrap script prompts once for the server Tailscale auth key (`tag:homeserver`), joins the tailnet, deploys the core stack (Caddy + whoami), and enables `homeserver-core.service`.

Application updates are delivered by **GitHub Actions** (rsync + deploy over SSH), not by git pull or cron on the server. See the homeserver [deploy.md](https://github.com/michelpl/homeserver/blob/main/docs/deploy.md).

## What stays out of this repo

- Tailscale **auth** (`tailscale up` / `TS_AUTHKEY` — owned by homeserver)
- Docker Compose application stacks (Caddy, whoami, …)
- Application secrets (`.env` in homeserver, gitignored)

## Re-running safely

All scripts are idempotent. Re-run `./setup.sh i homeserver-host` after pulling updates to this repository.
