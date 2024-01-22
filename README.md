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
- Set accent color to wallpaper in KDE
- `gpg --import private.key`

### Create self signed key
`openssl req -x509 -newkey rsa:4096 -keyout private-key.pem -out certificate.pem -days 9999 -subj "/CN=thuis.plebian.nl" -addext "basicConstraints=critical,CA:FALSE" -addext "subjectAltName=DNS:thuis.plebian.nl,DNS:*.thuis.plebian.nl"`

## Troubleshooting
#### GPG hangs
- `rm -rf ~/.gnupg/public-keys.d/*.lock`

#### QMK flashing
- `qmk compile -kb peej/lumberjack -km martijnboers`
- `qmk flash -kb peej/lumberjack -km martijnboers`

