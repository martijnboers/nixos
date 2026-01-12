{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.hyprland;
in
{
  imports = [ ./desktop.nix ];

  options.hosts.hyprland = {
    enable = mkEnableOption "The rice is ready";
  };

  config = mkIf cfg.enable {
    hosts.desktop.enable = true;

    environment.systemPackages = with pkgs; [
      file-roller # archive manager used by thunar
    ];

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-media-tags-plugin
        thunar-archive-plugin
        thunar-volman
      ];
    };

    services.tumbler.enable = true;
    services.gvfs.enable = true;

    services.greetd = {
      enable = true;
      settings = {
        # only first session auto-login
        initial_session = {
          command = "start-hyprland";
          user = "martijn";
        };
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --cmd Hyprland";
          user = "martijn";
        };
      };
    };

    # protocol for unpriv proces to speak to become privileged
    security.polkit.enable = true;

    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
  };
}
