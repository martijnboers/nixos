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

      # messaging
      signal-desktop
      telegram-desktop
      unstable.gossip # nostr client
    ];
  };
}
