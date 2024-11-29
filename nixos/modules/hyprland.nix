{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.hyprland;
in {
  imports = [./desktop.nix];

  options.hosts.hyprland = {
    enable = mkEnableOption "The rice is ready";
  };

  config = mkIf cfg.enable {
    hosts.desktop.enable = true;

    environment.systemPackages = with pkgs; [
      kdePackages.qtwayland
      lxqt.lxqt-policykit # lxqt polkit
    ];

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    xdg = {
      portal = {
        enable = true;
        config.common.default = "*"; # pick first in order, hyprland
        extraPortals = [
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-media-tags-plugin
        thunar-archive-plugin
        thunar-volman
      ];
    };
    services.tumbler.enable = true;

    services.greetd = {
      enable = true;
      settings = {
        # only first session auto-login
        initial_session = {
          command = "Hyprland";
          user = "martijn";
        };
        default_session = {
          command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd Hyprland";
          user = "martijn";
        };
        kde = {
          command = "startplasma-wayland";
          user = "martijn";
        };
      };
    };

    # Auth/permission management
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # hint electron apps to use wayland
      MOZ_ENABLE_WAYLAND = "1"; # ensure enable wayland for Firefox
      WLR_RENDERER_ALLOW_SOFTWARE = "1"; # enable software rendering for wlroots
      WLR_NO_HARDWARE_CURSORS = "1"; # disable hardware cursors for wlroots
      NIXOS_XDG_OPEN_USE_PORTAL = "1"; # needed to open apps after web login
      DEFAULT_BROWSER = "librewolf";
      QT_QPA_PLATFORMTHEME = "kde";
    };
  };
}
