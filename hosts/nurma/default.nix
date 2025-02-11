{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "nurma";
  hosts.hyprland.enable = true;

  hosts.borg = {
    enable = true;
    repository = "ssh://nads486h@nads486h.repo.borgbase.com/./repo";
    paths = ["/home/martijn"];
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

  programs = {
    gamemode = {
      enable = true;
    };
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            gamemode
          ];
      };
    };
    winbox = {
      enable = true;
      package = pkgs.winbox4;
      openFirewall = true;
    };
  };

  services.xserver.videoDrivers = ["amdgpu"];
  services.flatpak.enable = true;

  # Enable binfmt emulation of aarch64-linux. (for the raspberry pi)
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  hosts.auditd = {
    enable = true;
    rules = [
      "-w /home/martijn/.ssh -p rwa -k ssh_file_access"
      "-w /home/martijn/Nix -p rwa -k nix_config_changes"
      "-a exit,always -F arch=b64 -S execve -k program_run"
    ];
  };

  hosts.secrets = {
    identityPaths = [
      "/home/martijn/.ssh/id_ed25519_age"
    ];
  };

  services.yubikey-agent.enable = true;
  # for smartcard support
  services.pcscd.enable = true;
  security.pam.services = {
    login.u2fAuth = true;
    doas.u2fAuth = true;
  };

  programs.ssh.extraConfig = ''
    IdentityFile /home/martijn/.ssh/id_ed25519_sk
  '';

  programs.adb.enable = true;
  users.users.martijn.extraGroups = ["adbusers"];

  # Support gpg for git signing
  hosts.gpg.enable = true;

  # Docker + QEMU
  hosts.virtualisation = {
    enable = true;
    qemu = true;
  };

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
}
