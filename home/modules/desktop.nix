{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.maatwerk.desktop;
in {
  options.maatwerk.desktop = {
    enable = mkEnableOption "Enable default desktop packages + configuration";
  };

  config = mkIf cfg.enable {
    maatwerk.browser.enable = true;
    maatwerk.kitty.enable = true;
    maatwerk.stylix.enable = true;

    home.packages = with pkgs; [
      wl-clipboard # wayland clipboard manager
      kooha # record screen wayland
      wev # wayland xev

      yubioath-flutter # yubikey
      seafile-client
      cheese # webcam
      file-roller # archive manager

      # Office suite
      stable.libreoffice-qt
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US
      obsidian
    ];
  };
}
