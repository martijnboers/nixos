{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "donk";
  hosts.hyprland.enable = true;
  hosts.secureboot.enable = true;

  environment.systemPackages = [
    pkgs.iio-hyprland
    pkgs.wvkbd-desktop
  ];

  programs.ssh.extraConfig = ''
    IdentityFile /home/martijn/.ssh/id_keychain.sk
  '';

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;
    };
  };

  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519" ];

  hosts.borg = {
    enable = true;
    repository = "ssh://iuyrg38x@iuyrg38x.repo.borgbase.com/./repo";
    identityPath = "/home/martijn/.ssh/id_ed25519";
    paths = [ "/home/martijn" ];
    exclude = [
      ".cache"
      "*/cache2" # librewolf
      "*/Cache"
      ".wine"
      ".config/Slack/logs"
      ".config/Code/CachedData"
      ".container-diff"
      ".npm/_cacache"
      "*/node_modules"
      "*/_build"
      "*/venv"
      "*/.venv"
      "/home/*/.local"
      "/home/*/Downloads"
      "/home/*/Data"
      "/home/*/.ssh"
    ];
  };

  users.users.martijn = {
    hashedPasswordFile = lib.mkForce config.age.secrets.password-laptop.path;
  };

  hosts.tailscale.enable = true;
  hosts.prometheus.enable = true;

  # Allow network access when building shoryuken
  # https://mdleom.com/blog/2021/12/27/caddy-plugins-nixos/#xcaddy
  nix.settings.sandbox = false;

  # Enable binfmt emulation of aarch64-linux. (for the raspberry pi)
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Support gpg for git signing
  hosts.yubikey.enable = true;
}
