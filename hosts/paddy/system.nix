{
  pkgs,
  lib,
  outputs,
  ...
}: {
  networking.hostName = "macbook-martijn";
  networking.computerName = "macbook-martijn";
  system.defaults.smb.NetBIOSName = "macbook-martijn";

  homebrew = {
    enable = true;
    casks = [
      "rectangle"
      "eloston-chromium"
    ];
  };

  # Default env variables
  environment.variables = {
    EDITOR = "nvim";
  };

  users.users.martijn = {
    home = lib.mkForce "/Users/martijn";
  };

  system = {
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };

  # enable flakes globally
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix.package = pkgs.nix;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Disable auto-optimise-store because of this issue:
  #   https://github.com/NixOS/nix/issues/7273
  # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
  nix.settings = {
    auto-optimise-store = false;
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
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
      ../../nixos/keys/hadouken.crt
      ../../nixos/keys/shoryuken.crt
    ];
  };

  time.timeZone = "Europe/Amsterdam";
  nix.settings.trusted-users = ["martijn"];
  system.stateVersion = 5;
}
