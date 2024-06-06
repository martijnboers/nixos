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
    ../desktop.nix
    ./waybar.nix
    ./wofi.nix
  ];

  options.thuis.hyprland = {
    enable = mkEnableOption "Hyprland";
  };

  config = mkIf cfg.enable {
    thuis.desktop.enable = true;
    home.packages = with pkgs; [
      # utilities
      hyprpaper
      waybar
      rofi-wayland
      swaybg
      networkmanagerapplet

      # emojis
      wofi
      wofi-emoji
      wtype

      # screenshots / clipboard
      wl-clipboard
      flameshot

      # notifs
      dunst
    ];

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      # https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
      settings = {
        "$mod" = "ALT";
        "$prog" = "CTRL ALT";
        exec-once = [
          "swaybg --image /home/martijn/Nix/home/assets/wallpaper2.jpg"
          "npm-applet --indicator &"
          "dunst &"
          "copyq --start-server &"
        ];
        "$terminal" = "kitty";
        "$fileManager" = "thunar";
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
            "$mod, E, exec, wofi-emoji"
            ", Print, exec, flameshot gui" # https://github.com/flameshot-org/flameshot
            "$mod, F4, killactive"
            "$prog, H, exec, copyq toggle"

            # movement
            "$mod, V, togglefloating"
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"
            "$mod, P, pseudo," # dwindle
            "$mod, J, togglesplit" # dwindle
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
          gaps_out = 17;
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
