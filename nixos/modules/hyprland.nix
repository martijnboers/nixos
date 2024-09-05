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

    # Still necesarry for stylix
    environment.systemPackages = with pkgs; [
      libsForQt5.full
      libsForQt5.qt5.qtwayland
      lxqt.lxqt-policykit # lxqt polkit
    ];

    programs.hyprland = {
      enable = true;
    };

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    xdg = {
      menus.enable = true;
      portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    services.greetd = {
      enable = true;
      settings = {
        # only first session auto-login
        initial_session = {
          command = "dbus-run-session Hyprland";
          user = "martijn";
        };
        # need to run dbus-run-session to get xdg to pickup mimes :/
        # https://www.reddit.com/r/NixOS/comments/16g1sdy/xdgopen_not_working/
        default_session = {
          command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd \"dbus-run-session Hyprland\"";
          user = "martijn";
        };
      };
    };

    security.polkit.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # hint electron apps to use wayland
      MOZ_ENABLE_WAYLAND = "1"; # ensure enable wayland for Firefox
      WLR_RENDERER_ALLOW_SOFTWARE = "1"; # enable software rendering for wlroots
      WLR_NO_HARDWARE_CURSORS = "1"; # disable hardware cursors for wlroots
      NIXOS_XDG_OPEN_USE_PORTAL = "1"; # needed to open apps after web login
      DEFAULT_BROWSER = "firefox";
      QT_QPA_PLATFORMTHEME = "kde";
    };
  };
}
