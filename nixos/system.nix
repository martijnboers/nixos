{
  pkgs,
  config,
  outputs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./modules/virtualisation.nix
    ./modules/prometheus.nix
    ./modules/secureboot.nix
    ./modules/tailscale.nix
    ./modules/hyprland.nix
    ./modules/authdns.nix
    ./modules/auditd.nix
    ./modules/server.nix
    ./modules/derper.nix
    ./modules/borg.nix
    ./modules/ssh.nix
    ./modules/gpg.nix
  ];

  age.secrets = {
    password.file = ../secrets/password.age;
    password-laptop.file = ../secrets/password-laptop.age;
  };

  # User
  users = {
    mutableUsers = false;
    users.martijn = {
      shell = pkgs.zsh;
      isNormalUser = true;
      useDefaultShell = true;
      extraGroups = [
        "networkmanager"
        "wheel" # sudo
        "plugdev" # mounting
        "dialout" # serial
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
    inputs.agenix.packages.${system}.default

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
    jq

    # editor
    helix
    vim

    htop
    iotop # io monitoring
    iftop # network monitoring
    btop # fancy htop

    # archives
    zip
    unzip
    p7zip

    # diagnostic
    du-dust # better du
    screen
    killall # 🔪
    magic-wormhole # send files

    # system tools
    lsof # list open files
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    nfs-utils
    attic-client # own bincache

    # forensics
    uutils-coreutils-noprefix
    hexedit
    jless # cli json viewer
    avml # make memory dump
  ];

  nix = {
    channel.enable = lib.mkDefault false;
    settings = {
      experimental-features = [
        "nix-command"
        "pipe-operators"
      ];
      log-lines = lib.mkDefault 25;

      # Avoid disk full issues
      min-free = lib.mkDefault (512 * 1024 * 1024);

      # Fallback quickly if substituters are not available.
      connect-timeout = lib.mkDefault 3;

      # When doing deploys
      download-buffer-size = 524288000;

      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;

      # Allowed to connect to nix-daemon
      allowed-users = [ "martijn" ];

      substituters = [
        "https://cache.nixos.org?priority=1"
        "https://bincache.thuis/default"
        "https://install.determinate.systems"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "default:QiddKxFxKitj0NauDJDKT944qMq3bJvtHKNVlwsWz8k="
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
      "rekkaken.machine.thuis".publicKeyFile = ../secrets/keys/rekkaken.pub;
      "dosukoi.machine.thuis".publicKeyFile = ../secrets/keys/dosukoi.pub;
    }
    // (lib.attrsets.mergeAttrsList (
      map mkBorgRepo [
        "gak69wyz"
        "jym6959y"
        "iwa7rtli"
        "nads486h"
        "aebp8i08"
        "c4j3xt27"
        "llh048o5"
        "iuyrg38x"
      ]
    ));
  programs.zsh.enable = true;
  services.fwupd.enable = true; # firmware update

  networking = {
    firewall.enable = lib.mkDefault true;

    # tailscale overwrites this with 100.100.100.100 when connected
    nameservers = [
      "8.8.8.8"
      "2620:fe::fe"
      "149.112.112.112"
      "2620:fe::9"
    ];
    resolvconf = {
      # so dns servers don't use their own service
      useLocalResolver = lib.mkForce false;
    };
  };

  security = {
    sudo.enable = lib.mkDefault false; # 🦀🦀
    sudo-rs.enable = lib.mkDefault true; # 🦀🦀
    pki.certificateFiles = [
      ../secrets/keys/plebs4gold.crt
      ../secrets/keys/pfsense.crt
    ];
  };

  # by default setup gotify bridge as email
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      tls = "off";
      port = 2525;
    };
    accounts = {
      default = {
        host = "rekkaken.machine.thuis";
        user = "notif@thuis";
        from = "notif@thuis";
      };
    };
  };

  environment.etc."aliases".text = ''
    root: notif@thuis
    martijn: notif@thuis
  '';

  environment.sessionVariables = {
    EDITOR = "nvim";
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    TMOUT = (5 * 60 * 60); # zsh timeout
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  # Set time zone.
  time.timeZone = "Europe/Amsterdam";

  # Prefer NTS over NTP
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [ "ntp.time.nl" ];
  };

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

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.alternative-pkgs
    ];

    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-32.3.3" # eol
        "libxml2-2.13.8" # CVE-2025-6021
        "libsoup-2.74.3" # gnome cves
      ];
    };
  };

  # Keep journal log max 20gigs
  services.journald.extraConfig = ''
    SystemMaxUse=20G
    SystemKeepFree=100G
  '';

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "24.05";
}
