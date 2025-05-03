{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.maatwerk.personal;
in
{
  options.maatwerk.personal = {
    enable = mkEnableOption "Add personal computer configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mangohud # show fps etc
      qmk
      qflipper
      vlc
      gimp
      ollama # for the client
      electrum # btc wallet

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
