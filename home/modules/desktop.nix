{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.thuis.desktop;
in {
  options.thuis.desktop = {
    enable = mkEnableOption "Enable default desktop packages + configuration";
  };

  config = mkIf cfg.enable {
    thuis.browser.enable = true;
    thuis.kitty.enable = true;
    thuis.stylix.enable = true;

    home.packages = with pkgs; [
      wl-clipboard # wayland clipboard manager
      kooha # record screen wayland
      wev # wayland xev

      yubioath-flutter # yubikey
      seafile-client

      # Office suite
      stable.libreoffice-qt
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US
    ];
  };
}
