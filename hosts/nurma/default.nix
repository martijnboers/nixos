{ pkgs, config, ... }:
{
  networking.hostName = "nurma";
  hosts.hyprland.enable = true;
  hosts.secureboot.enable = true;

  hosts.borg = {
    enable = true;
    repository = "ssh://nads486h@nads486h.repo.borgbase.com/./repo";
    paths = [ "/home/martijn" ];
    identityPath = "/home/martijn/.ssh/id_ed25519_age";
    exclude = [
      ".cache"
      "*/cache2" # librewolf
      "*/Cache"
      ".wine"
      ".config/Slack/logs"
      ".config/Code/CachedData"
      ".container-diff"
      ".npm/_cacache"
      "Sync"
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

  hosts.tailscale.enable = true;
  hosts.prometheus.enable = true;

  age.secrets.nurma-client = {
    file = ../../secrets/nurma-client.age;
    owner = "root";
    group = "systemd-network";
  };

  networking.wg-quick.interfaces.wg0 = {
    autostart = false;
    address = [ "10.100.0.2/24" ];
    privateKeyFile = config.age.secrets.nurma-client.path;
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
    gamemode = {
      enable = true;
    };
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            gamemode
          ];
      };
    };
    winbox = {
      enable = true;
      package = pkgs.winbox4;
      openFirewall = true;
    };

    # Run unpatched bins
    nix-ld = {
      enable = true;
    };
  };

  hosts.openssh = {
    enable = false;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.10.0.0/24"
    ];
  };

  # Allow network access when building shoryuken
  # https://mdleom.com/blog/2021/12/27/caddy-plugins-nixos/#xcaddy
  nix.settings.sandbox = false;

  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable binfmt emulation of aarch64-linux. (for the raspberry pi)
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hosts.auditd = {
    enable = true;
    rules = [
      "-w /home/martijn/.ssh -p rwa -k ssh_file_access"
      "-w /home/martijn/Nix -p rwa -k nix_config_changes"
    ];
  };

  age = {
    identityPaths = [ "/home/martijn/.ssh/id_ed25519_age" ];
  };

  programs.ssh.extraConfig = ''
    IdentityFile /home/martijn/.ssh/id_ed25519_sk
  '';

  programs.adb.enable = true;
  users.users.martijn.extraGroups = [ "adbusers" ];

  # Support gpg for git signing
  hosts.gpg.enable = true;

  # Docker + QEMU
  hosts.virtualisation = {
    enable = true;
    qemu = true;
  };
}
