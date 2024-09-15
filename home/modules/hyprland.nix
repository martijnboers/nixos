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
    gtk = {
      enable = true;
      iconTheme.name = "gruvbox";
      iconTheme.package = pkgs.gruvbox-dark-icons-gtk;
    };

    xdg = let
      mimeDefinitions = {
        "application/pdf" = "zathura.desktop";
        "text/plain" = "kwrite.desktop";
        "text/html" = "webstorm.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";

        "image/gif" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/png" = "imv.desktop";
        "image/webp" = "imv.desktop";

        "video/mp4" = "vlc.desktop";
        "video/webm" = "vlc.desktop";

        "audio/flac" = "clementine.desktop";
        "audio/mpeg" = "clementine.desktop";
      };
    in {
      enable = true;
      mime.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = mimeDefinitions;
        associations.added = mimeDefinitions;
      };
    };

    home.packages = with pkgs;
    with kdePackages; [
      # utilities
      waybar
      rofi-wayland
      networkmanagerapplet
      blueman # bluetooth
      pavucontrol # audio
      playerctl
      wlogout
      imv # image viewer

      # KDE apps
      kate
      merkuro # kalender
      dolphin
      dolphin-plugins
      kdegraphics-thumbnailers
      kio
      kio-extras
      ffmpegthumbs
      gnome.seahorse # kwallet stinks

      # File support
      zathura #pdf
      vlc

      # emojis
      wofi-emoji
      wtype

      # screenshots / clipboard
      hyprshot
      wl-clipboard
      copyq

      # other
      swaynotificationcenter # notifs
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      # https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
      settings = {
        "$mod" = "ALT";
        "$prog" = "CTRL ALT";
        exec-once = [
          "nm-applet --indicator &"
          "swaync &"
          "copyq --start-server &"
          "blueman-applet &"
          "nheko &"
        ];
        "$terminal" = "kitty";
        "$fileManager" = "dolphin";
        "$browser" = "firefox";
        "$menu" = "rofi -show drun -show-icons";

        # hyprctl clients
        windowrulev2 = [
          "workspace 3, class:(sublime_merge)"
          "workspace 4, class:(nheko)"
          "workspace 4, class:(signal)"
          "workspace 4, class:(Slack)"
          "workspace 5, class:(steam)"
          "workspace 6, title:(Clementine)"
          "workspace 6, title:(Spotify Premium)"
        ];

        # l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
        # r -> release, will trigger on release of a key.
        # e -> repeat, will repeat when held.
        # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
        # m -> mouse, see below
        # t -> transparent, cannot be shadowed by other binds.
        # i -> ignore mods, will ignore modifiers.
        bindm = [
          "$mod,mouse:272,movewindow"
          "$mod,mouse:273,resizewindow"
        ];

        bindr = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 3%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 3%-"
        ];

        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        bind =
          [
            "$mod, W, exec, $browser"
            "$mod, Q, exec, $terminal"
            "$mod, E, exec, $fileManager"
            "$mod, Space, exec, $menu"
            "$mod, T, exec, wofi-emoji"
            "$mod, R, exec, pycharm-community"
            ", Print, exec, hyprshot -m region --clipboard-only" #
            "$mod, F4, killactive"
            "$prog, H, exec, copyq toggle"
            "$mod, M, exec, hyprlock"

            # movement
            # https://wiki.hyprland.org/Configuring/Dispatchers/#list-of-dispatchers
            "$mod, V, togglefloating"
            "$prog, down, workspace, -1"
            "$prog, up, workspace, +1"
            "$mod, J, movefocus, l"
            "$mod, L, movefocus, r"
            "$mod, I, movefocus, u"
            "$mod, K, movefocus, d"
            "$mod, U, swapwindow, l"
            "$mod, O, swapwindow, r"
            "$mod, F, fullscreen,"
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
              6)
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

          # https://github.com/danth/stylix/issues/430
          "col.active_border" = lib.mkForce "rgb(${config.lib.stylix.colors.base06})";
        };
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
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
      # Attempt at fixing youtube picture-in-picture
      extraConfig = ''
        windowrulev2 = keepaspectratio,class:^(firefox)$,title:^(Picture-in-Picture)$
        windowrulev2 = noborder,class:^(firefox)$,title:^(Picture-in-Picture)$
        windowrulev2 = fakefullscreen,class:^(firefox)$,title:^(Firefox)$
        windowrulev2 = fakefullscreen,class:^(firefox)$,title:^(Picture-in-Picture)$
        windowrulev2 = pin,class:^(firefox)$,title:^(Firefox)$
        windowrulev2 = pin,class:^(firefox)$,title:^(Picture-in-Picture)$
        windowrulev2 = float,class:^(firefox)$,title:^(Firefox)$
        windowrulev2 = float,class:^(firefox)$,title:^(Picture-in-Picture)$
      '';
    };

    home.file.".config/rofi/config.rasi" = {
      source = ../assets/css/runner.css;
    };

    services.wlsunset = {
      enable = true;
      latitude = "52.081038939033604";
      longitude = "4.306721564001391";
      temperature.night = 3000;
    };

    services.swayidle = let
      lockCmd = lib.getExe pkgs.hyprlock;
      hyprlandPkg = lib.getExe config.wayland.windowManager.hyprland.package;
    in {
      enable = true;
      events = [
        # executes command before systemd puts the computer to sleep.
        {
          event = "before-sleep";
          command = lockCmd;
        }
        # executes command when logind signals that the session should be locked
        {
          event = "lock";
          command = lockCmd;
        }
      ];
      timeouts = [
        {
          timeout = 1495;
          command = "${lib.getExe pkgs.libnotify} 'Locking in 5 seconds' -t 5000";
        }
        {
          timeout = 1500;
          command = lockCmd;
        }
        {
          timeout = 1600;
          command = "${hyprlandPkg} dispatch dpms off";
          resumeCommand = "${hyprlandPkg} dispatch dpms on";
        }
      ];
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 30;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 4;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = "Rara...";
            shadow_passes = 2;
          }
        ];
      };
    };
  };
}
