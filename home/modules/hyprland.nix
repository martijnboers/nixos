{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.thuis.hyprland;
  mod = "ALT";
in {
  imports = [./desktop.nix];

  options.thuis.hyprland = {
    enable = mkEnableOption "Rice is healthy";
  };

  config = mkIf cfg.enable {
    thuis.desktop.enable = true;
    home.packages = with pkgs; [
      # utilities
      hyprpaper
      waybar
      rofi-wayland

      # emojis
      wofi
      wofi-emoji
      wtype

      # screenshots / clipboard
      grim
      slurp
      wl-clipboard

      # notifs
      mako
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      settings = {
        exec-once = [
          "waybar &"
        ];
        decoration = {
          blur = {
            size = 8;
            passes = 3;
            noise = "0.02";
            contrast = "0.9";
            brightness = "0.9";
            popups = true;
            xray = false;
          };
          rounding = 10;
          dim_special = "0.0";
        };
        misc = {
          disable_hyprland_logo = true;
          animate_manual_resizes = false;
          animate_mouse_windowdragging = false;
          close_special_on_empty = true;
        };
        bind =
          [
            "${mod}, F, exec, firefox"
            "${mod}, T, exec, kitty"
            "${mod}, Space, exec, rofi -show run"
            "${mod}, E, exec, wofi-emoji"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
            builtins.concatLists (
              builtins.genList (
                x: let
                  ws = let
                    c = (x + 1) / 10;
                  in
                    builtins.toString (x + 1 - (c * 10));
                in [
                  "${mod}, ${ws}, workspace, ${toString (x + 1)}"
                  "${mod} SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                ]
              )
              10
            )
          );
        bindm = [
          "${mod},mouse:272,movewindow"
          "${mod},mouse:273,resizewindow"
        ];
      };
    };
    programs.waybar = {
      enable = true;
      settings = [
        {
          height = 35;
          layer = "top";
          position = "bottom";
          tray = {spacing = 10;};
          modules-left = ["hyprland/workspaces"];
          modules-center = ["hyprland/window"];
          modules-right = [
            "hyprland/language"
            "battery"
            "clock"
          ];

          "clock" = {
            interval = 60;
            format = "{:%H:%M}";
            max-length = 25;
          };
        }
      ];
      #    style = (builtins.readFile ../static-files/waybar-style.css);
    };
  };
}
