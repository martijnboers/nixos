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
    maatwerk.kitty.enable = true;
    maatwerk.stylix.enable = true;
    maatwerk.attic.enable = true;

    home.packages =
      with pkgs;
      with pkgs.kdePackages;
      [
        wl-clipboard # wayland clipboard manager
        kooha # record screen wayland
        wev # wayland xev
        cheese # webcam
        electrum # btc wallet
        errands # todo manager
	karlender # gtk calendar
	impala # wifi tui

        # file support
        zathura # pdf
        imv # image
        vlc # video
        kate # kwrite

        # work
        citrix_workspace
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
        cinny-desktop # matrix client
      ];

    programs.gpg = {
      enable = true;
      # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
      scdaemonSettings = {
        disable-ccid = true;
      };
    };
  };
}
