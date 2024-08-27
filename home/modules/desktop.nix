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
    home.packages = with pkgs; [
      firefox
      kitty
      ungoogled-chromium
      wl-clipboard # wayland clipboard manager
      kooha # record screen wayland

      yubioath-flutter # yubikey

      # Office suite
      libreoffice-qt
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US
    ];
  };
}
