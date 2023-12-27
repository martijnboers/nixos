{pkgs, ...}: {
  # User
  users.users.martijn = {
    isNormalUser = true;
    description = "Martijn Boers";
    extraGroups = ["networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };

  # Don't ask for sudo too often
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=100
  '';

  # Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Only keep the last 500MiB of systemd journal.
  services.journald.extraConfig = "SystemMaxUse=500M";

  # Collect nix store garbage and optimise daily.
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # misc
  programs.zsh.enable = true;

  # to get gpg to work
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 21600;
    };
  };

  # Docker configuration
  virtualisation.docker.enable = true;

  # Global packages
  environment.systemPackages = with pkgs; [
    # for gpg
    gnupg
    pinentry

    # archives
    zip
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq

    # networking tools
    dnsutils # `dig` + `nslookup`

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    git
    wev # wayland xev
    gcc
    tldr

    # samba
    cifs-utils

    htop
    btop # fancy htop
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    lsof # list open files

    # system tools
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];

  system.stateVersion = "23.11";
}
