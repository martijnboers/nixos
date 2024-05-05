<h1 align="center">
  <img src="home/assets/logo.svg" alt="nixos" width="250">
</h1>

## Description
NixOS is a Linux distribution with a unique package management system, Nix, offering precise control and reproducible configurations. 
It follows a declarative and functional programming approach, ensuring system reliability and easy rollback.

You could directly use this but it's better to extract the pieces 
you want in your own config. Checkout [nix-starter-config](https://github.com/Misterio77/nix-starter-configs)
for a good initial starting point for NixOS with flakes. 

> Linux is only free if your time has no value 
> 
> -- ___Jamie Zawinski___

### Fresh installation notes
- Create ISO: `nix run github:nix-community/nixos-generators -- --flake "/home/martijn/Nix#glassdoor" -f iso`
- Link flake file to home
- `sudo ln -s /home/martijn/Nix/flake.nix /etc/nixos/flake.nix`
- `sudo tailscale up --login-server https://headscale.plebian.nl`
- Set accent color to wallpaper in KDE
- `gpg --import private.key`
- `ssh-add ~/.ssh/id_ed25519`

### Troubleshooting
#### GPG hangs
- `rm -rf ~/.gnupg/public-keys.d/*.lock`

#### QMK flashing
- `qmk compile -kb peej/lumberjack -km martijnboers`
- `qmk flash -kb peej/lumberjack -km martijnboers`

