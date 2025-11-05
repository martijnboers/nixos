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

        # keyring
        seahorse
        gcr

        # file support
        zathura # pdf
        imv # image
        mpv # video
        kate # kwrite
        sqlitebrowser

        # yubikey
        yubioath-flutter # 2fa
        yubikey-manager # ykman

        # work
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
        mat2 # remove metadata
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
      # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
      scdaemonSettings = {
        disable-ccid = true;
      };
    };
  };
}
