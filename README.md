## Description
NixOS is a Linux distribution with a unique package management system, Nix, offering precise control and reproducible configurations.
It follows a declarative and functional programming approach, ensuring system reliability and easy rollback.

> 🌱 **Tired of Github?** This repository is available through Radicle
> View it here: [rad:z2Jkf9zxGPxEhCfGLpgRAcHRj8x2n](https://git.boers.email/nodes/seed.boers.email/rad:z2Jkf9zxGPxEhCfGLpgRAcHRj8x2n)

You could directly use this but it's better to extract the pieces
you want in your own config. Checkout [nix-starter-config](https://github.com/Misterio77/nix-starter-configs)
for a good initial starting point for NixOS with flakes.

### Services

#### Router

| Service | Description | Configuration |
| --- | --- | --- |
| ACME | ACME server for internal TLS certificates. | [acme.nix](hosts/dosukoi/modules/acme.nix) |
| AdGuard Home | Network-wide ad and tracker blocking DNS sinkhole. | [adguard.nix](hosts/dosukoi/modules/adguard.nix) |
| Blocklist | Manages a network-wide blocklist. | [blocklist.nix](hosts/dosukoi/modules/blocklist.nix) |
| Firewall | Manages network traffic rules using nftables. | [firewall.nix](hosts/dosukoi/modules/firewall.nix) |
| Interfaces | Configures network interfaces and PPPoE. | [interfaces.nix](hosts/dosukoi/modules/interfaces.nix) |
| ntopng | Network traffic monitoring tool. | [ntopng.nix](hosts/dosukoi/modules/ntopng.nix) |
| Vaultwarden | Password manager (Bitwarden compatible). | [vaultwarden.nix](hosts/dosukoi/modules/vaultwarden.nix) |
| WireGuard | VPN tunnel. | [wireguard.nix](hosts/dosukoi/modules/wireguard.nix) |

#### Main file server

| Service | Description | Configuration |
| --- | --- | --- |
| Shiori | Bookmark manager. | [archive.nix](hosts/hadouken/modules/archive.nix) |
| Atuin | Shell history synchronization. | [atuin.nix](hosts/hadouken/modules/atuin.nix) |
| Bincache | Caching for binary files. | [bincache.nix](hosts/hadouken/modules/bincache.nix) |
| Radicale | CalDAV and CardDAV server. | [calendar.nix](hosts/hadouken/modules/calendar.nix) |
| PostgreSQL, MinIO, pgAdmin | Database services and management. | [database.nix](hosts/hadouken/modules/database.nix) |
| Changedetection.io | Website change detection and notification service. | [detection.nix](hosts/hadouken/modules/detection.nix) |
| Immich | Self-hosted photo and video backup solution. | [immich.nix](hosts/hadouken/modules/immich.nix) |
| Mastodon (glitch-soc) & Fedifetcher | Federated social media server. | [mastodon.nix](hosts/hadouken/modules/mastodon.nix) |
| Matrix Synapse | Secure, decentralized communication server. | [matrix.nix](hosts/hadouken/modules/matrix.nix) |
| Jellyfin & Syncthing | Media server and file synchronization. | [media.nix](hosts/hadouken/modules/media.nix) |
| Microbin | Self-hosted pastebin. | [microbin.nix](hosts/hadouken/modules/microbin.nix) |
| Grafana, Loki, Promtail, Prometheus | Monitoring and logging stack. | [monitoring.nix](hosts/hadouken/modules/monitoring.nix) |
| Paperless-NGX | Document management system. | [paperless.nix](hosts/hadouken/modules/paperless.nix) |
| NFS | Network File System for sharing files. | [shares.nix](hosts/hadouken/modules/shares.nix) |
| ZFS & Syncoid | Manages ZFS filesystems and automated backups. | [storage.nix](hosts/hadouken/modules/storage.nix) |

#### Cloud #1

| Service | Description | Configuration |
| --- | --- | --- |
| Authoritative DNS | Authoritative DNS server. | [authdns.nix](nixos/modules/authdns.nix) |
| Derper | Tailscale DERP server. | [derper.nix](nixos/modules/derper.nix) |
| Headscale | Self-hosted Tailscale control server. | [headscale.nix](hosts/rekkaken/modules/headscale.nix) |
| Ladder | Self-hosted 12ft.io alternative. | [ladder.nix](hosts/rekkaken/modules/ladder.nix) |
| Gotify & smtp-gotify | Notification service with an SMTP bridge. | [notifs.nix](hosts/rekkaken/modules/notifs.nix) |
| Uptime Kuma | Service monitoring tool. | [uptime.nix](hosts/rekkaken/modules/uptime.nix) |

#### Cloud #2

| Service | Description | Configuration |
| --- | --- | --- |
| Authoritative DNS | Authoritative DNS server. | [authdns.nix](nixos/modules/authdns.nix) |
| Caddy | Reverse proxy and static file server. | [caddy.nix](hosts/shoryuken/modules/caddy.nix) |
| Derper | Tailscale DERP server. | [derper.nix](nixos/modules/derper.nix) |
| Endlessh | SSH tarpit. | [endlessh.nix](hosts/shoryuken/modules/endlessh.nix) |
| Pocket-ID | OIDC provider. | [oidc.nix](hosts/shoryuken/modules/oidc.nix) |

#### Bitcoin Node

| Service | Description | Configuration |
| --- | --- | --- |
| Bitcoin | Bitcoin node. | [bitcoin.nix](hosts/tatsumaki/modules/bitcoin.nix) |

#### Home Automation

| Service | Description | Configuration |
| --- | --- | --- |
| Cyberchef | The Cyber Swiss Army Knife. | [cyberchef.nix](hosts/tenshin/modules/cyberchef.nix) |
| Home Assistant | Home automation platform. | [hass.nix](hosts/tenshin/modules/hass.nix) |
| IT-Tools | A collection of useful online tools for developers. | [ittools.nix](hosts/tenshin/modules/ittools.nix) |
| NTP | Network Time Protocol daemon. | [ntp.nix](hosts/tenshin/modules/ntp.nix) |


