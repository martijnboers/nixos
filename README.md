## Description
Personal NixOS files. Mostly plagiarized from other configurations. 

> Linux is only free if your time has no value 
> 
> -- ___Jamie Zawinski___

## Fresh installation notes
Link flake file to home

- `sudo ln -s /home/martijn/Nix/flake.nix /etc/nixos/flake.nix`


#### Set  samba secrets
```bash
❯ cat /etc/nixos/smb-secrets
username=user
password=password
```

#### Import private key
```bash
gpg --import private.key
```

### Age
`sudo mkdir /var/lib/sops-nix`

`cp keys.txt /var/lib/sops-nix/keys.txt`
## Troubleshooting
#### GPG hangs
- `rm -rf ~/.gnupg/public-keys.d/*.lock`

#### QMK flashing
- `qmk compile -kb peej/lumberjack -km martijnboers`
- `qmk flash -kb peej/lumberjack -km martijnboers`

#### Delete old generations
- `nix-collect-garbage`
