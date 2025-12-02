{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.hyprland;

  # On-screen keyboard toggle for battery widget
  oskToggle = pkgs.writeShellScriptBin "osk" ''
    PROG="wvkbd"
    SIGNAL="SIGRTMIN"
    if ! pgrep "''${PROG}" > /dev/null; then
        "''${PROG}" --hidden --alpha 204 &
    fi
    pkill --signal "''${SIGNAL}" "''${PROG}"
  '';

  # Screen rotation toggle for disk widget
  iioToggle = pkgs.writeShellScriptBin "iio-toggle" ''
    PROG="iio-hyprland"
    if ! pgrep "''${PROG}" > /dev/null; then
      "''${PROG}" &
    else
      pkill "''${PROG}"
    fi
  '';

  # WAN IP display script
  wanIP = pkgs.writeShellScriptBin "wan-ip" ''
    wan_ip=$(curl -s https://ip.boers.email)
    echo "󰖟 $wan_ip"
  '';

  # Quick settings menu
  quickSettings = pkgs.writeShellScriptBin "quick-settings" ''
    # Define options with icons
    options="⌨️  Keyboard\n🔄  Rotation"

    # Show wofi menu with larger font/padding for touch
    chosen=$(echo -e "$options" | wofi \
      --dmenu \
      --hide-search \
      --insensitive \
      --prompt "" \
      --width 300 \
      --height 200 \
      --cache-file /dev/null \
      --style ${pkgs.writeText "wofi-quicksettings.css" ''
        #entry {
          padding: 20px;
          font-size: 20px;
        }
      ''})

    # Execute based on selection
    case "$chosen" in
      "⌨️  Keyboard")
        ${lib.getExe oskToggle}
        ;;
      "🔄  Rotation")
        ${lib.getExe iioToggle}
        ;;
    esac
  '';
in
{
  config = mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      settings = {
        single_click = true;
      };
    };
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = # css
        ''
          @define-color base00 #0d0c0c;
          @define-color base01 #1d1c19;
          @define-color base02 #282727;
          @define-color base03 #737c73;
          @define-color base04 #a6a69c;
          @define-color base05 #c5c9c5;
          @define-color base06 #7a8382;
          @define-color base07 #c5c9c5;
          @define-color base08 #c4746e;
          @define-color base09 #b98d7b;
          @define-color base0A #c4b28a;
          @define-color base0B #87a987;
          @define-color base0C #8ea4a2;
          @define-color base0D #8ba4b0;
          @define-color base0E #8992a7;
          @define-color base0F #a292a3;

          * {
            min-height: 0;
            font-family: ${config.stylix.fonts.monospace.name};
            font-size: ${toString config.stylix.fonts.sizes.terminal}px;
            border: none;
            border-radius: 0;
          }

          window#waybar {
            background: transparent;
            color: @base03;
            transition-property: background-color;
            transition-duration: 0.5s;
          }

          #custom-power, #custom-quick-settings, #workspaces, #custom-notification,
          #custom-wan, #window, #clock-privacy, #system-stats, #system-tray {
              background: @base01;
              border: 1px solid @base02;
              border-radius: 12px;
              margin: 0 4px 0 0;
              padding: 5px 12px;
              font-weight: 600;
              transition: background-color 0.3s ease;
          }

          #custom-power:hover, #custom-quick-settings:hover, #custom-notification:hover,
          #custom-wan:hover, #window:hover, #clock-privacy:hover,
          #system-stats:hover, #system-tray:hover {
            background: @base02;
          }

          #custom-power {
            color: @base0A;
            padding-left: 15px;
            padding-right: 15px;
            border-right: 1px solid @base03;
            margin-right: 0;
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
          }

          #window {
            color: @base05;
          }

          #custom-notification,
          #custom-wan {
            color: @base04;
          }

          #custom-quick-settings {
            color: @base0C;
            padding-left: 15px;
            padding-right: 20px;
            border-top-left-radius: 0;
            border-bottom-left-radius: 0;
            border-left: none;
            margin-left: 0;
          }

          #workspaces {
            padding: 4px 8px;
          }

          #workspaces button {
            color: @base0A;
            font-weight: 600;
            margin: 0;
            background-color: transparent;
            transition: all 0.3s ease;
            padding: 0 4px;
          }

          #workspaces button:hover {
            background-color: @base02;
            border-radius: 8px;
          }

          #workspaces button.active {
            color: @base03;
            background-color: @base0A;
            border-radius: 8px;
          }

          #workspaces button.urgent { color: @base08; }
          #workspaces button.empty { color: @base03; }
          #workspaces button.focused { color: @base0A; }

          window#waybar.empty #window {
              background-color: transparent;
              border-color: transparent;
          }

          tooltip {
            background-color: @base01;
            border: 1px solid @base02;
            border-radius: 12px;
            padding: 10px;
          }

          tooltip label {
            color: @base05;
          }

          #battery.charging { color: @base0B; }
          #battery.warning:not(.charging) { color: @base0A }
          #battery.critical:not(.charging) { color: @base08; }
          #network.disconnected { color: @base08; }

          #clock, #privacy, #cpu, #temperature, #disk, #idle_inhibitor,
          #memory, #battery, #wireplumber, #pulseaudio, #bluetooth, #network {
            background: transparent;
            border: none;
            color: @base04;
            padding: 0;
          }

          #clock {
            font-weight: 700;
          }

          #privacy {
            border-left: 1px solid @base03;
            padding-left: 10px;
            margin-left: 10px;
          }

          #network {
            padding-right: 8px;
          }

          #battery, #idle_inhibitor, #bluetooth, #cpu, #disk, #temperature, #wireplumber {
            border-right: 1px solid @base03;
            padding-right: 10px;
            margin-right: 10px;
          }
        '';
      settings = [
        {
          layer = "top";
          position = "top";
          margin-left = 12;
          margin-right = 12;
          margin-top = 5;
          spacing = 0;

          modules-left = [
            "custom/power"
            "custom/quick-settings"
            "hyprland/workspaces"
            "hyprland/window"
          ];
          modules-center = [
            "group/clock-privacy"
          ];
          modules-right = [
            "custom/wan"
            "group/system-stats"
            "group/system-tray"
          ];

          "hyprland/workspaces" = {
            on-click = "activate";
            # https:#github.com/Alexays/Waybar/wiki/Module:-Workspaces#persistent-workspaces
            persistent-workspaces = {
              "1" = [ ];
              "2" = [ ];
              "3" = [ ];
              "4" = [ ];
              "5" = [ ];
              "6" = [ ];
            };
            format = "{icon}";
            # https://www.nerdfonts.com/cheat-sheet
            format-icons = {
              "1" = "󰹈";
              "2" = "󰭆";
              "3" = "󱌚";
              "4" = "";
              "5" = "";
              "6" = "󰻈";
            };
          };

          "hyprland.window" = {
            format = "{}";
            icon = true;
          };

          clock = {
            interval = 60;
            format = "{:%a %b %d <b>%H:%M</b>}";
            tooltip-format = "<big>{calendar}</big>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='#ffcb6b'><b>{}</b></span>";
                weekdays = "<span color='#b2ccd6'><b>{}</b></span>";
                weeks = "<span color='#585b70'><b>W{}</b></span>";
                days = "<span color='#eeffff'><b>{}</b></span>";
                today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };

          cpu = {
            interval = 2;
            format = "  {usage}%";
            min-length = 6;
            tooltip = true;
            tooltip-format = "<b>CPU</b>\nLoad: {load}%\nFrequency: {avg_frequency} GHz";
          };

          network = {
            format-wifi = "󱚻";
            format-ethernet = "󰈀";
            format-disconnected = "󱘖";
            tooltip = true;
            tooltip-format-wifi = "<b>{essid}</b>\nSignal Strength: {signalStrength}%";
            on-click = "iwgtk";
          };

          bluetooth = {
            format = " {status}";
            format-connected = " {num_connections}";
            tooltip = true;
            tooltip-format = "Bluetooth: {status}";
            tooltip-format-connected = "<b>{device_alias}</b>\nBattery: {device_battery_percentage}%";
            on-click = "blueman-manager";
          };

          "group/system-tray" = {
            orientation = "horizontal";
            modules = [
              "wireplumber"
              "battery"
              "bluetooth"
              "network"
            ];
          };

          "group/clock-privacy" = {
            orientation = "horizontal";
            modules = [
              "idle_inhibitor"
              "clock"
              "privacy"
            ];
          };

          "group/system-stats" = {
            orientation = "horizontal";
            modules = [
              "cpu"
              "temperature"
              "disk"
              "memory"
            ];
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
          };

          memory = {
            interval = 2;
            format = "  {}%";
          };

          battery = {
            interval = 2;
            states = {
              warning = 25;
              critical = 10;
            };
            format = "  {capacity}%";
            format-charging = "󱐋 {capacity}%";
            format-warning = "󰚥 {capacity}%";
            format-critical = "󱗗 {capacity}%";
          };

          disk = {
            interval = 15;
            format = "󰋊 {percentage_used}%";
            path = "/";
          };

          wireplumber = {
            format = "{icon}  {volume}%";
            format-bluetooth = "{icon}  {volume}% 󰂯";
            format-bluetooth-muted = "󰖁 {icon} 󰂯";
            format-muted = "󰖁 {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "󰋋";
              hands-free = "󱡒";
              headset = "󰋎";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };

          "custom/power" = {
            tooltip = false;
            format = "{icon}";
            format-icons = "⏻";
            exec-on-event = "true";
            on-click = "wlogout";
          };

          "custom/quick-settings" = {
            tooltip = false;
            format = "{icon}";
            format-icons = "";
            exec-on-event = "true";
            on-click = lib.getExe quickSettings;
          };

          "custom/wan" = {
            tooltip = false;
            exec = lib.getExe wanIP;
            interval = 5;
          };

          temperature = {
            # for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
            "hwmon-path" = "/sys/class/hwmon/hwmon1/temp2_input";
            format = "󰈸 {temperatureC}°C";
          };

          privacy = {
            icon-size = 14;
            icon-spacing = 5;
            modules = [
              {
                type = "screenshare";
                tooltip = true;
              }
              {
                type = "audio-out";
                tooltip = true;
              }
              {
                type = "audio-in";
                tooltip = true;
              }
            ];
          };

          "custom/sepp" = {
            format = "|";
          };
        }
      ];
    };
  };
}
