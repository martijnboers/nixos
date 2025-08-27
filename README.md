## Description
NixOS is a Linux distribution with a unique package management system, Nix, offering precise control and reproducible configurations. 
It follows a declarative and functional programming approach, ensuring system reliability and easy rollback.

You could directly use this but it's better to extract the pieces 
you want in your own config. Checkout [nix-starter-config](https://github.com/Misterio77/nix-starter-configs)
for a good initial starting point for NixOS with flakes. 

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

