{
  pkgs,
  lib,
  outputs,
  ...
}:
{
  networking.hostName = "macbook-martijn";
  networking.computerName = "macbook-martijn";

  # Default env variables
  environment.variables = {
    EDITOR = "nvim";
    QMK_HOME = "~/Code/qmk_firmware";
  };

  users.users.martijn = {
    home = lib.mkForce "/Users/martijn";
  };

  # enable flakes globally
  nix = {
    package = pkgs.nix;
    linux-builder.enable = true; # cross-compile to x86_64-linux
    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
    settings = {
      # Disable auto-optimise-store because of this issue:
      #   https://github.com/NixOS/nix/issues/7273
      # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
      auto-optimise-store = false;
      trusted-users = [ "martijn" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];

    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.alternative-pkgs
    ];
    hostPlatform = lib.mkDefault "aarch64-darwin";

    config = {
      allowUnfree = true;
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];

  security = {
    pki.certificateFiles = [
      ../../secrets/keys/hadouken.crt
      ../../secrets/keys/shoryuken.crt
    ];
  };

  time.timeZone = "Europe/Amsterdam";
  system.stateVersion = 5;
}
