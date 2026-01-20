{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./modules/prometheus.nix
    ./modules/secureboot.nix
    ./modules/tailscale.nix
    ./modules/hyprland.nix
    ./modules/authdns.nix
    ./modules/auditd.nix
    ./modules/server.nix
    ./modules/derper.nix
    ./modules/yubi.nix
    ./modules/oidc.nix
    ./modules/borg.nix
    ./modules/qemu.nix
    ./modules/ssh.nix
  ];

  age.secrets = {
    password.file = lib.mkDefault ../secrets/password.age;
    password-laptop.file = lib.mkDefault ../secrets/password-laptop.age;
  };

  users = {
    mutableUsers = false;
    users.martijn = {
      shell = pkgs.zsh;
      isNormalUser = true;
      useDefaultShell = true;
      extraGroups = [
        "wheel" # sudo
        "plugdev" # mounting
        "dialout" # serial
        "tss" # tpm
        "network"
      ];
      openssh.authorizedKeys.keyFiles = [
        ../secrets/keys/nurma-sk.pub
        ../secrets/keys/keychain-sk.pub
      ];
      hashedPasswordFile = config.age.secrets.password.path;
    };
  };

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default

    # core
    uutils-coreutils-noprefix
    ripgrep
    openssl
    file
    which
    pass
    tree
    gawk
    git
    wget
    vim

    # admin
    htop # the og
    btop # fancy htop
    exfatprogs # fat support
    e2fsprogs # mkfs.ext4 etc

    # networking
    dnsutils # dig+dnslookup
    geonet # geodns+geoping
    rdap # whois

    # archives
    lz4 # compression
    zip
    unzip
    gnutar

    # diagnostic
    dust # better du
    screen
    croc # send files
    unaware # mask PII-data

    # system tools
    lm_sensors # for `sensors` command
    pciutils # lspci
    usbutils # lsusb
    nfs-utils

    # forensics
    binutils # strings+ld
    hexyl # hexviewer
    jless # cli json viewer
    jq # query json
    avml # make memory dump
    minicom # serial port reader
  ];

  nix = {
    channel.enable = lib.mkDefault false;
    package = inputs.determinate.packages.${pkgs.system}.default;

    settings = {
      experimental-features = [
        "nix-command"
        "pipe-operators"
        "flakes"
      ];
      log-lines = lib.mkDefault 25;

      # Avoid disk full issues
      min-free = lib.mkDefault (512 * 1024 * 1024);

      # Fallback quickly if substituters are not available.
      connect-timeout = lib.mkDefault 3;

      # When doing deploys
      download-buffer-size = (512 * 1024 * 1024);

      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;

      # Allowed to connect to nix-daemon
      allowed-users = [ "martijn" ];

      substituters = [
        "https://bincache.thuis/default"
        "https://nix-community.cachix.org"
        "https://install.determinate.systems"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "default:QiddKxFxKitj0NauDJDKT944qMq3bJvtHKNVlwsWz8k="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      ];
    };

    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  programs.ssh = {
    startAgent = true;
    knownHosts =
      let
        mkBorgRepo = name: {
          "${name}.repo.borgbase.com" = {
            publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOstKfBbwVOYQh3J7X4nzd6/VYgLfaucP9z5n4cpSzcZAOKGh6jH8e1mhQ4YupthlsdPKyFFZ3pKo4mTaRRuiJo=";
          };
        };
        mkServer = name: {
          "${name}.machine.thuis".publicKeyFile = ../secrets/keys/${name}.pub;
        };
      in
      {
        "github.com".publicKey =
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
        "gitlab.com".publicKey =
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=";
      }
      // (lib.attrsets.mergeAttrsList (
        map mkServer [
          "hadouken"
          "tenshin"
          "tatsumaki"
          "shoryuken"
          "dosukoi"
          "rekkaken"
          "suzaku"
        ]
      ))
      // (lib.attrsets.mergeAttrsList (
        map mkBorgRepo [
          "aebp8i08"
          "c4j3xt27"
          "gak69wyz"
          "iuyrg38x"
          "iwa7rtli"
          "jh49p12c"
          "jym6959y"
          "llh048o5"
          "nads486h"
          "nkhm1dhr"
        ]
      ));
  };

  programs.zsh.enable = true;
  services.fwupd.enable = true; # firmware update

  networking = {
    useDHCP = false; # Done by networkd
    firewall.enable = lib.mkDefault true;
    nftables.enable = lib.mkDefault true;
  };
  systemd.network.enable = true;

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic";

    # When active, Tailscale is the only DNS, rest fallbackDns
    fallbackDns = [
      "9.9.9.9#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
      "193.110.81.0#dns0.eu"
      "2a0f:fc80::#dns0.eu"
      "185.253.5.0#dns0.eu"
      "2a0f:fc81::#dns0.eu"
    ];
  };

  security = {
    sudo.enable = lib.mkDefault false; # 🦀🦀
    sudo-rs.enable = lib.mkDefault true; # 🦀🦀
    pki.certificateFiles = [ ../secrets/keys/plebs4platinum.crt ];
    tpm2.enable = true;
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
    REQUESTS_CA_BUNDLE = config.security.pki.caBundle; # python
    NODE_EXTRA_CA_CERTS = config.security.pki.caBundle; # node
    SSL_CERT_FILE = config.security.pki.caBundle; # rust+go etc
    TMOUT = (5 * 60 * 60); # zsh timeout
  };

  time.timeZone = "Europe/Amsterdam";
  services.chrony = {
    enable = true;
    enableNTS = lib.mkDefault true;
    servers = lib.mkDefault [
      "ntppool1.time.nl"
      "ntppool2.time.nl"

      "194.58.200.20" # Netnod (Sweden)
      "194.58.201.20" # Netnod (Sweden)
      "192.53.103.108" # PTB (Germany)
    ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # Keep journal log max 20gigs
  services.journald.extraConfig = ''
    SystemMaxUse=20G
    SystemKeepFree=100G
  '';

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "24.05";
}
