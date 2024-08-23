{config, ...}: {
  networking.hostName = "glassdoor";
  hosts.hyprland.enable = true;

  hosts.borg = {
    enable = true;
    repository = "ssh://nads486h@nads486h.repo.borgbase.com/./repo";
    paths = ["/home/martijn"];
    identityPath = "/home/martijn/.ssh/id_ed25519_age";
    exclude = [
      ".cache"
      "*/cache2" # firefox
      "*/Cache"
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

  # Enable tailscale network
  hosts.tailscale.enable = true;

  # SDR
  hardware.rtl-sdr.enable = true;
  users.users.martijn.extraGroups = ["plugdev"];

  services.xserver.videoDrivers = ["amdgpu"];
  services.flatpak.enable = true;

  hosts.auditd = {
    enable = true;
    rules = [
      "-w /home/martijn/.ssh -p rwa -k ssh_file_access"
      "-w /home/martijn/Nix -p rwa -k nix_config_changes"
      "-a exit,always -F arch=b64 -S execve -k program_run"
    ];
  };

  fileSystems."/mnt/music" = {
    device = "//hadouken.machine.thuis/music";
    fsType = "cifs";
    options = ["credentials=${config.age.secrets.smb.path},uid=1000,gid=100"];
  };
  fileSystems."/mnt/misc" = {
    device = "//hadouken.machine.thuis/misc";
    fsType = "cifs";
    options = ["credentials=${config.age.secrets.smb.path},uid=1000,gid=100"];
  };

  services.yubikey-agent.enable = true;
  security.pam.yubico = {
    enable = true;
    mode = "challenge-response";
    id = "25580427";
  };

  hosts.secrets = {
    identityPaths = [
      "/home/martijn/.ssh/id_ed25519_age"
    ];
  };

  programs.ssh.extraConfig = ''
    IdentityFile /home/martijn/.ssh/id_ed25519_sk
  '';

  virtualisation.virtualbox = {
    host.enable = true;
    host.enableExtensionPack = true;
    guest.enable = true;
    guest.draganddrop = true;
  };

  # Support gpg for git signing
  hosts.gpg.enable = true;

  # Docker + QEMU
  hosts.virtualization.enable = true;

  # Bootloader.
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      # hopefully fixes crashing AMD GPU
      grub.extraConfig = ''
        amdgpu.aspm=0
      '';
    };

    # Silent Boot
    # https://wiki.archlinux.org/title/Silent_boot
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    # https://github.com/NixOS/nixpkgs/pull/108294
    initrd = {
      verbose = false;
      kernelModules = ["amdgpu"];
    };
  };

  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714; # Kde connect
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714; # Kde connect
        to = 1764;
      }
    ];
  };
}
