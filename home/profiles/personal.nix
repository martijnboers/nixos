{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.hosts.personal;
in {
  options.hosts.personal = {
    enable = mkEnableOption "Add personal computer configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      steam
      wine
      clementine
      spotify
      qmk
      qflipper

      # messaging
      signal-desktop
      telegram-desktop
    ];
  };
}
