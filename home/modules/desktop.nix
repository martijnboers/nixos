{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.desktop;
in
{
  options.maatwerk.desktop = {
    enable = mkEnableOption "Enable default desktop packages + configuration";
  };

  config = mkIf cfg.enable {
    maatwerk.browser.enable = true;
    maatwerk.ghostty.enable = true;
    maatwerk.stylix.enable = true;
    maatwerk.attic.enable = true;

    services.gnome-keyring.enable = true;

    home.packages =
      with pkgs;
      with pkgs.kdePackages;
      [
        wl-clipboard # wayland clipboard manager
        kooha # record screen wayland
        wev # wayland xev
        cheese # webcam
        errands # todo manager
        karlender # gtk calendar
        dezoomify-rs # art archival
        localsend # airdrop

        # keyring
        seahorse
        gcr

        # file support
        zathura # pdf
        imv # image
        mpv # video
        xfce.mousepad # gui-notepad
        sqlitebrowser

        # work (https://github.com/NixOS/nixpkgs/pull/464965)
        (citrix_workspace.overrideAttrs (oa: {
          buildInputs = (oa.buildInputs or [ ]) ++ [ stable.webkitgtk_4_0 ];
          meta = (oa.meta or { }) // {
            # https://github.com/NixOS/nixpkgs/issues/454151
            broken = false;
          };
        }))

        # networking
        wireguard-tools # wg-quick
        podman-compose # replace for dud
        iwgtk # wifi applet

        # forensics
        sleuthkit # fls, icat
        binwalk # firmware analysis
        magika # recognize filetype
        mat2 # remove metadata
        ent # test entropy files
        exiftool # read metadata
        rdap # whois
        nmap
        xca

        # programming
        sublime-merge
        devenv

        # music
        strawberry
        spotify

        # messaging
        signal-desktop
        fractal # matrix-client
      ];

    programs.distrobox = {
      enable = true;
      settings = {
        container_manager = "podman";
      };
      # distrobox-assemble create --file ~/.config/distrobox/containers.ini
      containers = {
        debian = {
          entry = true;
          image = "debian:13";
        };
        arch = {
          entry = true;
          image = "archlinux:latest";
        };
        fedora = {
          entry = true;
          image = "fedora:44";
        };
      };
    };

    programs.gpg = {
      enable = true;
      scdaemonSettings = {
        # Use system PCSC driver
        disable-ccid = true;
        # Allow OpenSC to touch the card
        pcsc-shared = true;
        # Stop GPG from blocking Firefox
        disable-application = "piv";
        # Timeout: 5 seconds (per OpenSC docs) or 30 seconds (for better cache)
        # 5s is safer for preventing errors; 30s is better for typing PIN less.
        card-timeout = "5";
      };
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = false;
      pinentryPackage = pkgs.pinentry-gnome3;
      defaultCacheTtl = 43200;
      maxCacheTtl = 43200;
    };

  };
}
