{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "paddy";
  hosts.hyprland.enable = true;
  # hosts.secureboot.enable = true;

  # programs.ssh.extraConfig = ''
  #   IdentityFile /home/martijn/.ssh/id_ed25519_sk
  # '';

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
    repository = "ssh://nkhm1dhr@nkhm1dhr.repo.borgbase.com/./repo";
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
    hashedPasswordFile = lib.mkForce null;
    # hashedPasswordFile = lib.mkForce config.age.secrets.password-laptop.path;
    hashedPassword = "$y$j9T$VQL/82faMlZSrWg9SefdB/$RQpwhho.v0avZJcjate9yXdzDxVRdBBXeui7ch5XYm9";
  };

  hosts.tailscale.enable = true;
  hosts.prometheus.enable = true;

  # Support gpg for git signing
  hosts.gpg.enable = true;
}
