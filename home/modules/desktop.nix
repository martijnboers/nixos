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
    thuis.kitty.enable = true;

    home.packages = with pkgs; [
      firefox
      kitty
      ungoogled-chromium
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

    programs.librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "identity.fxaccounts.enabled" = true;
        "identity.sync.tokenserver.uri" = "https://sync.thuis/1.0/sync/1.5";
        "privacy.clearOnShutdown.history" = false;
      };
    };
  };
}
