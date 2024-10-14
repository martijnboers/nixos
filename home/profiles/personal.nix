{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.thuis.personal;
in {
  options.thuis.personal = {
    enable = mkEnableOption "Add personal computer configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      stable.steam
      mangohud # show fps etc
      qmk
      qflipper
      vlc
      gimp
      ollama # for the client

      # music
      clementine
      spotify

      # messaging
      signal-desktop
      telegram-desktop
      nheko # matrix client
    ];
  };
}
