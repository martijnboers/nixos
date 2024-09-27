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

    home.packages = with pkgs; [
      wl-clipboard # wayland clipboard manager
      kooha # record screen wayland

      yubioath-flutter # yubikey
      nextcloud-client

      # Office suite
      libreoffice-qt
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US
    ];
  };
}
