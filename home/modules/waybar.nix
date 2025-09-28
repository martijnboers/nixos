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
          spacing = 1;

          modules-left = [
            "custom/power"
            "hyprland/workspaces"
            "hyprland/window"
          ];
          modules-center = [
            "clock"
            "calendar"
            "privacy"
          ];
          modules-right = [
            "custom/wan"
            "temperature"
            "cpu"
            "disk"
            "pulseaudio"
            "battery"
            "tray"
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

          tray = {
            icon-size = 18;
            spacing = 5;
            show-passive-items = true;
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
            tooltip = false;
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

          network = {
            interval = 2;
            format = "󰓅 {bandwidthTotalBits}";
            format-disconnected = "󰌙 Disconnected";
            tooltip-format = "󰖟  {ifname} 󰥔  {frequency} 󰅧  {bandwidthUpBits}   {bandwidthDownBits}";
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

          pulseaudio = {
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
            # "thermal-zone": 2,
            "hwmon-path" = "/sys/class/hwmon/hwmon2/temp1_input";
            format = "󰈸 {temperatureC}°C";
          };

          privacy = {
            icon-size = 18;
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
