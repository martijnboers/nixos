{
  pkgs,
  config,
  outputs,
  lib,
  ...
}: {
  imports = [
    ./modules/virtualisation.nix
    ./modules/prometheus.nix
    ./modules/syncthing.nix
    ./modules/tailscale.nix
    ./modules/hyprland.nix
    ./modules/secrets.nix
    ./modules/auditd.nix
    ./modules/server.nix
    ./modules/borg.nix
    ./modules/ssh.nix
    ./modules/gpg.nix
    ./modules/kde.nix
    ./modules/smb.nix
  ];

  age.secrets.password.file = ../secrets/password.age;

  # User
  users = {
    mutableUsers = false;
    users.martijn = {
      isNormalUser = true;
      description = "Martijn Boers";
      extraGroups = ["networkmanager" "wheel" "plugdev"];
      shell = pkgs.zsh;
      useDefaultShell = true;
      openssh.authorizedKeys.keyFiles = [
        ../secrets/keys/nurma-sk.pub
        ../secrets/keys/keychain-sk.pub
      ];
      hashedPasswordFile = config.age.secrets.password.path;
    };
  };

  # Global packages
  environment.systemPackages = with pkgs; [
    borgbackup

    # networking tools
    dnsutils # `dig` + `nslookup`
    whois

    # misc
    file
    which
    tree
    gnutar
    gawk
    lz4
    git
    wget

    # samba
    cifs-utils

    htop
    iotop # io monitoring
    iftop # network monitoring
    du-dust # better du
    screen

    # system call monitoring
    lsof # list open files

    # system tools
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    (doas-sudo-shim.overrideAttrs {version = "0.1.1";}) # needed for --use-remote-sudo
    hydra-check # check nixos ci builds
    openssl # for internal headscale pki
  ];

  nix = {
    # only using flakes
    channel.enable = lib.mkDefault false;
    settings = {
      experimental-features = ["nix-command" "flakes" "pipe-operators"];
      log-lines = lib.mkDefault 25;

      # Avoid disk full issues
      min-free = lib.mkDefault (512 * 1024 * 1024);

      # Fallback quickly if substituters are not available.
      connect-timeout = lib.mkDefault 3;

      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;

      # Allowed to connect to nix-daemon
      allowed-users = ["martijn"];

      substituters = [
        "https://cache.nixos.org?priority=1"
        "https://nix-community.cachix.org?priority=2"
        "https://binarycache.thuis?priority=3"
        "https://cache.garnix.io"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "binarycache.thuis:/alus5dkMvukzWHoAvbQ5qvjxISw+t9Cbo/nk129zSQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };

    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  programs.ssh.knownHosts = {
    "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "gitlab.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    "hadouken.machine.thuis".publicKeyFile = ../secrets/keys/hadouken.pub;
    "tenshin.machine.thuis".publicKeyFile = ../secrets/keys/tenshin.pub;
    "shoryuken.machine.thuis".publicKeyFile = ../secrets/keys/shoryuken.pub;
  };

  # misc
  programs.zsh.enable = true;

  security = {
    doas.enable = true;
    sudo.enable = false;
    doas.extraRules = [
      {
        users = ["martijn"];
        # Optional, retains environment variables while running commands
        # e.g. retains your NIX_PATH when applying your config
        keepEnv = true;
        persist = true; # Optional, only require password verification a single time
      }
    ];
    pki.certificateFiles = [
      ../secrets/keys/hadouken.crt
      ../secrets/keys/shoryuken.crt
      ../secrets/keys/tenshin.crt
    ];
  };

  # by default setup gotify bridge as email
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      tls = "off";
      port = 8025;
    };
    accounts = {
      default = {
        host = "shoryuken.machine.thuis";
        user = "notif@thuis";
        from = "notif@thuis";
      };
    };
  };

  environment.etc."aliases".text = ''
    root: notif@thuis
    martijn: notif@thuis
  '';

  # Default env variables
  environment.sessionVariables = {
    EDITOR = "nvim";
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
  };

  # Set time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "olm-3.2.16" # https://matrix.org/blog/2024/08/libolm-deprecation/
        "cinny-unwrapped-4.2.3"
      ];
    };
  };

  # Keep journal log max 20gigs
  services.journald.extraConfig = ''
    SystemMaxUse=20G
    SystemKeepFree=100G
  '';
  
    systemd = {
      # Given that our systems are headless, emergency mode is useless.
      # We prefer the system to attempt to continue booting so
      # that we can hopefully still access it remotely.
      enableEmergencyMode = false;

      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      watchdog = {
        # systemd will send a signal to the hardware watchdog at half
        # the interval defined here, so every 7.5s.
        # If the hardware watchdog does not get a signal for 15s,
        # it will forcefully reboot the system.
        runtimeTime = "15s";
        # Forcefully reboot if the final stage of the reboot
        # hangs without progress for more than 30s.
        # For more info, see:
        #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
        rebootTime = "30s";
        # Forcefully reboot when a host hangs after kexec.
        # This may be the case when the firmware does not support kexec.
        kexecTime = "1m";
      };
    };

  environment.etc."pki-root.cnf".text = ''
    [ req ]
    default_bits       = 4096
    default_md         = sha256
    prompt             = no
    distinguished_name = req_distinguished_name
    x509_extensions    = v3_ca

    [ req_distinguished_name ]
    CN                 = plebs4cash
    O                  = plebs4cash
    C                  = NL

    [ v3_ca ]
    basicConstraints   = critical, CA:true
    keyUsage           = critical, keyCertSign, cRLSign
    subjectKeyIdentifier = hash
    nameConstraints = critical, permitted;DNS:.thuis
  '';

  system.stateVersion = "24.05";
}
