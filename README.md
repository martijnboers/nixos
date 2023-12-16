## Description
Personal NixOS files. Mostly plagiarized from other configurations. 

> Linux is only free if your time has no value 
> 
> -- ___Jamie Zawinski___

### Fresh install notes
Link flake file to home

`sudo ln -s /home/martijn/Nix/flake.nix /etc/nixos/flake.nix`


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

#### LazyVim
`git clone https://github.com/LazyVimg/starter ~/.config/nvim`

#### GPG hangs
`rm -rf ~/.gnupg/public-keys.d/*.lock`
