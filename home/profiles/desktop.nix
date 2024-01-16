{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.hosts.desktop;
in {
  options.hosts.desktop = {
    enable = mkEnableOption "Enable default desktop packages + configuration";
    ipaddress = mkOption {
      type = types.str;
      default = "undefined";
      description = "Hostname of the computer";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox
      kitty
      ungoogled-chromium
      libsForQt5.kdeconnect-kde
      libsForQt5.neochat
      libsForQt5.kompare
      libsForQt5.kate
      wl-clipboard # wayland clipboard manager
      obsidian

      # music
      clementine
      spotify

      # theming
      nordic
      materia-kde-theme
      gimp
    ];
  };
}
