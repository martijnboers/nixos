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
      steam
      wine
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
      cinny-desktop # matrix client
    ];
  };
}
