# Mastodon Glitch Edition

<https://github.com/glitch-soc/mastodon>

Based on [nixpkgs upstream](https://github.com/NixOS/nixpkgs/tree/master/pkgs/servers/mastodon).

Modifications for the new yarn berry lockfiles and some other improvements stolen and adjusted (with permissions) from [catgirl.cloud](https://git.catgirl.cloud/999eagle/dotfiles-nix/-/tree/main/overlay/mastodon/glitch) (see also https://github.com/NixOS/nixpkgs/issues/277697).

I've also made some further modifications myself to try and simplify the package and better understand it.

## Updating

The package can be updated to the latest glitch-soc commit with `update.sh`.

- the `deps.patch` for the yarn lockfile will probably not work anymore
- in that case, delete it before running `update.sh`
- then try to build the package
- when it fails again with a yarn error, run `nix log` to get the full yarn output
- take the diff from there and adjust `deps.patch` accordingly
- also, the yarn hash in `version_data.nix` has to be adjusted manually
- build the package and paste the hash from the error message into `yarnHash`
