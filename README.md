<h1 align="center">
  <img src="home/assets/img/logo.svg" alt="nixos" width="250">
</h1>

## Description
NixOS is a Linux distribution with a unique package management system, Nix, offering precise control and reproducible configurations. 
It follows a declarative and functional programming approach, ensuring system reliability and easy rollback.

You could directly use this but it's better to extract the pieces 
you want in your own config. Checkout [nix-starter-config](https://github.com/Misterio77/nix-starter-configs)
for a good initial starting point for NixOS with flakes. 


### Fresh installation notes
- `git clone --recursive https://github.com/martijnboers/nixos.git ~/Nix`
- `sudo nixos-rebuild switch --flake ~/Nix#host`
- `doas tailscale up --login-server https://headscale.donder.cloud`
- `gpg --import private.key`
- `ssh-add ~/.ssh/id_ed25519`

### Hetzner
```
SSHPASS=<pwd> nix run github:nix-community/nixos-anywhere -- --flake .#shoryuken --env-password root@<ip>
```

### Rasperry Pi SD image
```
nix run nixpkgs#nixos-generators -- -f sd-aarch64 --flake .#tenshin --system aarch64-linux -o ~/pi.img
nixos-rebuild switch --flake .#tenshin --target-host 10.11.0.15 --use-remote-sudo
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
borgfs -f ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo::hadouken-default-2024-03-24T00:00:00 /mnt/restore
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

