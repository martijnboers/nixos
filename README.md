## Description
NixOS is a Linux distribution with a unique package management system, Nix, offering precise control and reproducible configurations. 
It follows a declarative and functional programming approach, ensuring system reliability and easy rollback.

You could directly use this but it's better to extract the pieces 
you want in your own config. Checkout [nix-starter-config](https://github.com/Misterio77/nix-starter-configs)
for a good initial starting point for NixOS with flakes. 

### Services

#### Router
| Service | Description | Configuration |
| --- | --- | --- |
| AdGuard Home | Network-wide ad and tracker blocking DNS sinkhole. | [adguard.nix](hosts/dosukoi/modules/adguard.nix) |
| Firewall | Manages network traffic rules using nftables. | [firewall.nix](hosts/dosukoi/modules/firewall.nix) |
| Interfaces | Configures network interfaces and PPPoE. | [interfaces.nix](hosts/dosukoi/modules/interfaces.nix) |

#### Main file server
| Service | Description | Configuration |
| --- | --- | --- |
| Shiori | Bookmark manager. | [archive.nix](hosts/hadouken/modules/archive.nix) |
| Atuin | Shell history synchronization. | [atuin.nix](hosts/hadouken/modules/atuin.nix) |
| Radicale | CalDAV and CardDAV server. | [calendar.nix](hosts/hadouken/modules/calendar.nix) |
| PostgreSQL, MinIO, pgAdmin | Database services and management. | [database.nix](hosts/hadouken/modules/database.nix) |
| Changedetection.io | Website change detection and notification service. | [detection.nix](hosts/hadouken/modules/detection.nix) |
| Immich | Self-hosted photo and video backup solution. | [immich.nix](hosts/hadouken/modules/immich.nix) |
| Ollama & Open WebUI | Local AI model hosting and web interface. | [llm.nix](hosts/hadouken/modules/llm.nix) |
| Mastodon (glitch-soc) & Fedifetcher | Federated social media server. | [mastodon.nix](hosts/hadouken/modules/mastodon.nix) |
| Matrix Synapse | Secure, decentralized communication server. | [matrix.nix](hosts/hadouken/modules/matrix.nix) |
| Microbin | Self-hosted pastebin. | [microbin.nix](hosts/hadouken/modules/microbin.nix) |
| Grafana, Loki, Promtail, Prometheus | Monitoring and logging stack. | [monitoring.nix](hosts/hadouken/modules/monitoring.nix) |
| Paperless-NGX | Document management system. | [paperless.nix](hosts/hadouken/modules/paperless.nix) |
| Pingvin Share | File sharing service. | [pingvin.nix](hosts/hadouken/modules/pingvin.nix) |
| Plex | Media server. | [plex.nix](hosts/hadouken/modules/plex.nix) |
| NFS | Network File System for sharing files. | [shares.nix](hosts/hadouken/modules/shares.nix) |
| ZFS & Syncoid | Manages ZFS filesystems and automated backups. | [storage.nix](hosts/hadouken/modules/storage.nix) |
| Syncthing | Continuous file synchronization. | [syncthing.nix](hosts/hadouken/modules/syncthing.nix) |
| Vaultwarden | Password manager (Bitwarden compatible). | [vaultwarden.nix](hosts/hadouken/modules/vaultwarden.nix) |

#### Cloud #1
| Service | Description | Configuration |
| --- | --- | --- |
| Headscale | Self-hosted Tailscale control server. | [headscale.nix](hosts/rekkaken/modules/headscale.nix) |
| Gotify & smtp-gotify | Notification service with an SMTP bridge. | [notifs.nix](hosts/rekkaken/modules/notifs.nix) |
| Uptime Kuma | Service monitoring tool. | [uptime.nix](hosts/rekkaken/modules/uptime.nix) |

#### Cloud #2
| Service | Description | Configuration |
| --- | --- | --- |
| Caddy (ACME Server) | Internal Certificate Authority. | [acme.nix](hosts/shoryuken/modules/acme.nix) |
| Caddy | Reverse proxy and static file server. | [caddy.nix](hosts/shoryuken/modules/caddy.nix) |
| Endlessh | SSH tarpit. | [endlessh.nix](hosts/shoryuken/modules/endlessh.nix) |
| Pocket-ID | OIDC provider. | [oidc.nix](hosts/shoryuken/modules/oidc.nix) |


### Hetzner
Start Ubuntu machine
```
users.users.martijn = {
    initialHashedPassword = "$y$j9T$odaa/qh6qtG0EgcuoYg2Z0$Aji4299/VffEHOJeT71/OIvjHcDovCy.quKGuilQKo8";
};
SSHPASS=<pwd> nix run github:nix-community/nixos-anywhere -- --flake '.?submodules=1#shoryuken' --env-password root@<ip>
```

### Rasperry Pi SD image
```
nix run nixpkgs#nixos-generators -- -f sd-aarch64 --flake '.?submodules=1#tenshin' --system aarch64-linux -o ~/pi.img
```

### Build vm image
```
nix build .#nixosConfigurations.usyk.config.system.build.vm
```

### Loading repl
```commandline
nix repl
nix-repl> :lf /home/martijn/Nix
nix-repl> nixosConfigurations.[TAB]
```

### Restore backups
```commandline
borg list ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo
borg mount ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo ~/RWDir
```

### Update firmware
```
fwupdmgr get-devices
fwupdmgr get-updates
fwupdmgr update
```

### Documentation
| project           | link |
|-------------------| ---- |
| `quickemu`        | https://github.com/quickemu-project/quickemu/wiki/05-Advanced-quickemu-configuration |
| `microvm`         | https://astro.github.io/microvm.nix |
| `nixvim`          | https://nix-community.github.io/nixvim/NeovimOptions/index.html |
| `agenix`          | https://github.com/ryantm/agenix/tree/main/doc |
| `home-manager`    | https://home-manager-options.extranix.com/ |
| `stylix`          | https://danth.github.io/stylix/ |
| `realtek-re-kmod` | https://www.freshports.org/net/realtek-re-kmod |

