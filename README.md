## Description
Personal NixOS files. Mostly plagiarized from other configurations. 

> Linux is only free if your time has no value 
> 
> -- ___Jamie Zawinski___

## Fresh installation notes
- Create ISO: `nix run github:nix-community/nixos-generators -- --flake "/home/martijn/Nix#glassdoor" -f iso`
- Link flake file to home
- `sudo ln -s /home/martijn/Nix/flake.nix /etc/nixos/flake.nix`
- `sudo tailscale up --login-server https://headscale.plebian.nl`
#### Import private key
```bash
gpg --import private.key
```

## Troubleshooting
#### GPG hangs
- `rm -rf ~/.gnupg/public-keys.d/*.lock`

#### QMK flashing
- `qmk compile -kb peej/lumberjack -km martijnboers`
- `qmk flash -kb peej/lumberjack -km martijnboers`

