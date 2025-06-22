{ pkgs, ... }:
{
  networking.hostName = "nurma";
  hosts.hyprland.enable = true;

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
      "-a exit,always -F arch=b64 -S execve -k program_run"
    ];
  };

  hosts.secrets = {
    identityPaths = [
      "/home/martijn/.ssh/id_ed25519_age"
    ];
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

  # Default setup for caddy pki
  environment.etc."pki-intermediate.cnf".text = ''
    [ req ]
    distinguished_name = req_distinguished_name

    [ req_distinguished_name ]
    # Keep it simple for intermediate

    [ v3_intermediate_ca ]
    subjectKeyIdentifier = hash
    authorityKeyIdentifier = keyid:always  
    basicConstraints = critical, CA:true, pathlen:0
    keyUsage = critical, digitalSignature, cRLSign, keyCertSign
    nameConstraints = critical, permitted;DNS:.thuis, permitted;DNS:thuis
  '';

  environment.etc."ssl/openssl.cnf".text = ''
    [openssl_init] 
    engines=engine_section 
    [engine_section] 
    pkcs11 = pkcs11_section 
    [pkcs11_section] 
    engine_id = pkcs11 
    dynamic_path = ${pkgs.opensc}/lib/opensc-pkcs11.so
    MODULE_PATH = ${pkgs.libp11}/lib/engines/pkcs11.so
    PIN = "safest" 
    init = 0

    module: ${pkgs.opensc}/lib/onepin-opensc-pkcs11.so
  '';

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
      kernelModules = [ "amdgpu" ];
    };
  };
}
