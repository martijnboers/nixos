{
  pkgs,
  config,
  outputs,
  ...
}: {
  imports = [
    ./modules/virtualization.nix
    ./modules/syncthing.nix
    ./modules/tailscale.nix
    ./modules/hyprland.nix
    ./modules/secrets.nix
    ./modules/auditd.nix
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
      extraGroups = ["networkmanager" "wheel"];
      shell = pkgs.zsh;
      useDefaultShell = true;
      openssh.authorizedKeys.keyFiles = [
        ./keys/glassdoor-sk.pub
        ./keys/keychain-sk.pub
      ];
      hashedPasswordFile = config.age.secrets.password.path;
    };
  };

  # Global packages
  environment.systemPackages = with pkgs; [
    # for gpg
    gnupg
    pinentry

    # archives
    zip
    unzip
    p7zip
    borgbackup # backups

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    tldr # man summarized

    # networking tools
    dnsutils # `dig` + `nslookup`

    # misc
    file
    which
    tree
    gnutar
    gawk
    zstd
    git
    wev # wayland xev
    gcc
    wget

    # samba
    cifs-utils

    htop
    btop # fancy htop
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
    cachix # community binary caches
    doas-sudo-shim # sadly necessary for some applications to work
    killall # 🔪
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];

    # Only martijn can access Nix deamon
    allowed-users = ["martijn"];
    trusted-users = ["martijn"];
  };

  # Collect nix store garbage and optimise daily.
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;

  # Enable networking
  networking.networkmanager.enable = true;

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
      ./keys/hadouken.crt
      ./keys/shoryuken.crt
    ];
  };

  # by default setup gotify bridge as email
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      port = 2525;
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
  };

  # SMB network discovery
  services.gvfs.enable = true;

  # Enable firewall by default
  networking.firewall = {
    enable = true;
    # Samba sharing discovery
    extraCommands = ''
      iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns
    '';
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
      outputs.overlays.unstable-packages
    ];

    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "olm-3.2.16" # https://matrix.org/blog/2024/08/libolm-deprecation/
      ];
    };
  };

  # Keep journal log max 20gigs
  services.journald.extraConfig = ''
    SystemMaxUse=20G
    SystemKeepFree=100G
  '';

  system.stateVersion = "24.05";
}
