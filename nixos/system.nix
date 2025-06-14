{
  pkgs,
  config,
  outputs,
  lib,
  ...
}:
{
  imports = [
    ./modules/virtualisation.nix
    ./modules/prometheus.nix
    ./modules/tailscale.nix
    ./modules/hyprland.nix
    ./modules/secrets.nix
    ./modules/authdns.nix
    ./modules/auditd.nix
    ./modules/server.nix
    ./modules/borg.nix
    ./modules/ssh.nix
    ./modules/gpg.nix
  ];

  age.secrets.password.file = ../secrets/password.age;

  # User
  users = {
    mutableUsers = false;
    users.martijn = {
      shell = pkgs.zsh;
      isNormalUser = true;
      useDefaultShell = true;
      extraGroups = [
        "networkmanager"
        "wheel"
        "plugdev"
      ];
      openssh.authorizedKeys.keyFiles = [
        ../secrets/keys/nurma-sk.pub
        ../secrets/keys/keychain-sk.pub
      ];
      hashedPasswordFile = config.age.secrets.password.path;
    };
  };

  # Global packages (also available to root)
  environment.systemPackages = with pkgs; [
    # networking tools
    dnsutils # `dig` + `nslookup`
    whois

    # misc
    ripgrep
    file
    which
    tree
    gnutar
    gawk
    lz4
    git
    wget

    # editors
    neovim
    helix

    htop
    iotop # io monitoring
    iftop # network monitoring
    btop # fancy htop

    # diagnostic
    du-dust # better du
    screen
    killall # 🔪

    # system tools
    lsof # list open files
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    nfs-utils

    # forensics
    veracrypt
    uutils-coreutils-noprefix
    hexedit
    jless # cli json viewer
    tio # serial
    avml # make memory dump
  ];

  nix = {
    channel.enable = lib.mkDefault false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      log-lines = lib.mkDefault 25;

      # Avoid disk full issues
      min-free = lib.mkDefault (512 * 1024 * 1024);

      # Fallback quickly if substituters are not available.
      connect-timeout = lib.mkDefault 3;

      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;

      # Allowed to connect to nix-daemon
      allowed-users = [ "martijn" ];

      substituters = [
        "https://cache.nixos.org?priority=1"
        "https://nix-community.cachix.org?priority=2"
        # "https://binarycache.thuis"
        "https://cache.garnix.io"
        "https://devenv.cachix.org"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "binarycache.thuis:/alus5dkMvukzWHoAvbQ5qvjxISw+t9Cbo/nk129zSQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  programs.ssh.knownHosts =
    let
      mkBorgRepo = name: {
        "${name}.repo.borgbase.com" = {
          publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOstKfBbwVOYQh3J7X4nzd6/VYgLfaucP9z5n4cpSzcZAOKGh6jH8e1mhQ4YupthlsdPKyFFZ3pKo4mTaRRuiJo=";
        };
      };
    in
    {
      "github.com".publicKey =
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
      "gitlab.com".publicKey =
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=";

      "hadouken.machine.thuis".publicKeyFile = ../secrets/keys/hadouken.pub;
      "tenshin.machine.thuis".publicKeyFile = ../secrets/keys/tenshin.pub;
      "tatsumaki.machine.thuis".publicKeyFile = ../secrets/keys/tatsumaki.pub;
      "shoryuken.machine.thuis".publicKeyFile = ../secrets/keys/shoryuken.pub;
    }
    // (lib.attrsets.mergeAttrsList (
      map mkBorgRepo [
        "gak69wyz"
        "jym6959y"
        "iwa7rtli"
        "nads486h"
        "aebp8i08"
      ]
    ));
  programs.zsh.enable = true;
  # default value, but should never be disabled
  networking.firewall.enable = lib.mkForce true;

  security = {
    sudo.enable = lib.mkDefault false; # 🦀🦀
    sudo-rs.enable = lib.mkDefault true; # 🦀🦀
    pki.certificateFiles = [
      ../secrets/keys/hadouken.crt
      ../secrets/keys/shoryuken.crt
      ../secrets/keys/tenshin.crt
      ../secrets/keys/tatsumaki.crt
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

  # mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enables mDNS name resolution for all applications (hostname.local)
    openFirewall = true; # Automatically opens UDP port 5353 in the firewall
  };

  environment.sessionVariables = {
    EDITOR = "nvim";
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    TMOUT = (5 * 60 * 60); # zsh timeout
    NIXPKGS_ALLOW_UNFREE = 1;
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
      outputs.overlays.alternative-pkgs
    ];

    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "cinny-unwrapped-4.2.3"
        "electron-32.3.3" # eol
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
