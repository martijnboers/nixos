{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.hyprland;
in
{
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = lib.mkForce ../assets/css/waybar.css;
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
            format = "  {capacity}%";
            format-charging = "󱐋 {capacity}%";
            on-click =
              let
                osk = pkgs.writeShellScriptBin "osk" ''
                  PROG="wvkbd"
                  SIGNAL="SIGRTMIN"
                  if ! pgrep "''${PROG}" > /dev/null; then
                      "''${PROG}" --hidden --alpha 204 &
                  fi
                  pkill --signal "''${SIGNAL}" "''${PROG}"
                '';
              in
              lib.getExe osk;
          };

          disk = {
            interval = 15;
            format = "󰋊 {percentage_used}%";
            path = "/";
            on-click =
              let
                osk = pkgs.writeShellScriptBin "osk" ''
                  PROG="iio-hyprland"
                  if ! pgrep "''${PROG}" > /dev/null; then
                    "''${PROG}" &
                  else
                    pkill "''${PROG}"
                  fi
                '';
              in
              lib.getExe osk;
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
            format-icons = "";
            exec-on-event = "true";
            on-click = "wlogout";
          };

          "custom/wan" = {
            tooltip = false;
            exec =
              let
                wan = pkgs.writeShellScriptBin "wan-ip" ''
                  wan_ip=$(curl -s https://ip.boers.email)
                  echo "󰖟 $wan_ip"
                '';
              in
              lib.getExe wan;
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
