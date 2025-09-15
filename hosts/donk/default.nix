{ pkgs, config, ... }:
{
  networking.hostName = "donk";
  hosts.hyprland.enable = true;
  hosts.secureboot.enable = true;

  hosts.uefi = {
    enable = true;
    crypto = true;
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
    initialHashedPassword = "$y$j9T$B4qf64SyCW89SDSvoUiEc1$2nYvLO1mDbJ7Z./c8KD97y0f2Mtdsnx03mmTcD3Xmb7"; # todo: change
  };

  hosts.tailscale.enable = true;
  hosts.prometheus.enable = true;

  age.secrets.donk-client = {
    file = ../../secrets/donk-client.age;
    owner = "root";
    group = "systemd-network";
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

  boot = {
    # Silent Boot
    # https://wiki.archlinux.org/title/Silent_boot
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    # https://github.com/NixOS/nixpkgs/pull/108294
    initrd.verbose = false;
  };
}
