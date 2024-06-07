{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.thuis.hyprland;
in {
  imports = [
    ./desktop.nix
    ./waybar.nix
  ];

  options.thuis.hyprland = {
    enable = mkEnableOption "Hyprland";
  };

  config = mkIf cfg.enable {
    thuis.desktop.enable = true;
    gtk.enable = true;
    qt.enable = true;

    home.packages = with pkgs; [
      # utilities
      hyprpaper
      waybar
      rofi-wayland
      swaybg
      networkmanagerapplet
      cinnamon.nemo-with-extensions
      blueman # bluetooth
      pavucontrol # audio

      # emojis
      wofi
      wofi-emoji
      wtype

      # screenshots / clipboard
      wl-clipboard
      hyprshot
      copyq

      # notifs
      swaynotificationcenter
    ];

    home.file.".config/swaync/style.css" = {
      source = ../assets/css/notifications.css;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      # https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
      settings = {
        "$mod" = "ALT";
        "$prog" = "CTRL ALT";
        exec-once = [
          "swaybg --mode fill --image /home/martijn/Nix/home/assets/wallpaper2.jpg"
          "nm-applet --indicator &"
          "swaync &"
          "copyq --start-server &"
        ];
        "$terminal" = "kitty";
        "$fileManager" = "nemo";
        "$browser" = "firefox";
        "$menu" = "rofi -show drun -show-icons";

        bindm = [
          "$mod,mouse:272,movewindow"
          "$mod,mouse:273,resizewindow"
        ];

        bind =
          [
            "$mod, Q, exec, $browser"
            "$mod, W, exec, $terminal"
            "$mod, E, exec, $fileManager"
            "$mod, Space, exec, $menu"
            "$mod, T, exec, wofi-emoji"
            "$mod, R, exec, pycharm-community"
            ", Print, exec, hyprshot -m region --clipboard-only" # https://github.com/flameshot-org/flameshot
            "$mod, F4, killactive"
            "$prog, H, exec, copyq toggle"

            # movement
            # https://wiki.hyprland.org/Configuring/Dispatchers/#list-of-dispatchers
            "$mod, V, togglefloating"
            "$mod, J, movefocus, l"
            "$mod, L, movefocus, r"
            "$mod, I, movefocus, u"
            "$mod, K, movefocus, d"
            "$mod, U, swapwindow, l"
            "$mod, O, swapwindow, r"
            "$mod, Y, fullscreen,"
            "$mod, P, pseudo," # dwindle
            "$mod, H, togglesplit" # dwindle
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
            builtins.concatLists (builtins.genList (
                x: let
                  ws = let
                    c = (x + 1) / 10;
                  in
                    builtins.toString (x + 1 - (c * 10));
                in [
                  "$mod, ${ws}, workspace, ${toString (x + 1)}"
                  "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                ]
              )
              10)
          );

        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle = {
          pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # You probably want this
        };
        general = {
          gaps_in = 3;
          gaps_out = "5,12,12,12";
          border_size = 2;

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;
          layout = "dwindle";
        };
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          sensitivity = 0; # # -1.0 - 1.0, 0 means no modification.
          touchpad = {
            natural_scroll = false;
          };
        };

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
      };
    };
  };
}
