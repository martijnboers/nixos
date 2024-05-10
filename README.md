<h1 align="center">
  <img src="home/assets/logo.svg" alt="nixos" width="250">
</h1>

## Description
NixOS is a Linux distribution with a unique package management system, Nix, offering precise control and reproducible configurations. 
It follows a declarative and functional programming approach, ensuring system reliability and easy rollback.

You could directly use this but it's better to extract the pieces 
you want in your own config. Checkout [nix-starter-config](https://github.com/Misterio77/nix-starter-configs)
for a good initial starting point for NixOS with flakes. 


### Fresh installation notes
- `sudo ln -s /home/martijn/Nix/flake.nix /etc/nixos/flake.nix`
- `sudo tailscale up --login-server https://headscale.plebian.nl`
- Set accent color to wallpaper in KDE
- `gpg --import private.key`
- `ssh-add ~/.ssh/id_ed25519`


### Documentation
| project    | link |
|------------| ---- |
| `quickemu` | https://github.com/quickemu-project/quickemu/wiki/05-Advanced-quickemu-configuration |
| `microvm`  | https://astro.github.io/microvm.nix |
| `nixvim`   | https://nix-community.github.io/nixvim/NeovimOptions/index.html |
| `agenix`   | https://github.com/ryantm/agenix/tree/main/doc |

