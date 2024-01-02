## Description
Personal NixOS files. Mostly plagiarized from other configurations. 

> Linux is only free if your time has no value 
> 
> -- ___Jamie Zawinski___

## Fresh installation notes
- Create ISO: `nix run github:nix-community/nixos-generators -- --flake "/home/martijn/Nix#glassdoor" -f iso`
- Link flake file to home
- `sudo ln -s /home/martijn/Nix/flake.nix /etc/nixos/flake.nix`

#### Import private key
```bash
gpg --import private.key
```

```bash
cp ssh ~/.ssh
```
## Troubleshooting
#### GPG hangs
- `rm -rf ~/.gnupg/public-keys.d/*.lock`

#### QMK flashing
- `qmk compile -kb peej/lumberjack -km martijnboers`
- `qmk flash -kb peej/lumberjack -km martijnboers`

