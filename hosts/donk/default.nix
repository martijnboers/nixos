{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  networking.hostName = "donk";
  hosts.hyprland.enable = true;
  hosts.secureboot.enable = true;

  environment.systemPackages = [
    inputs.iio-hyprland.packages.${pkgs.system}.default
    pkgs.wvkbd-desktop
  ];

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

  hosts.borg = {
    enable = true;
    repository = "ssh://iuyrg38x@iuyrg38x.repo.borgbase.com/./repo";
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

  age.secrets.donk-client = {
    file = ../../secrets/donk-client.age;
    owner = "root";
    group = "systemd-network";
  };

  age = {
    identityPaths = [ "/home/martijn/.ssh/id_ed25519" ];
  };

  networking.wg-quick.interfaces.wg0 = {
    autostart = false;
    address = [ "10.100.0.2/24" ];
    privateKeyFile = config.age.secrets.donk-client.path;
    dns = [ "9.9.9.9" ];
    peers = [
      {
        publicKey = "ePwQxnfNxjAdRYFtzvVTEZFBPnynQS/2FZ43R9fuHHQ=";
        endpoint = "${config.hidden.wan_ips.rekkaken}:51820";
        allowedIPs = [ "0.0.0.0/0" ];
        persistentKeepalive = 25;
      }
    ];
  };

  programs = {
    # Run unpatched bins
    nix-ld = {
      enable = true;
    };
  };

  # Allow network access when building shoryuken
  # https://mdleom.com/blog/2021/12/27/caddy-plugins-nixos/#xcaddy
  nix.settings.sandbox = false;

  # Enable binfmt emulation of aarch64-linux. (for the raspberry pi)
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Support gpg for git signing
  hosts.gpg.enable = true;
}
