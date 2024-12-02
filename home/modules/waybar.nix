{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.thuis.hyprland;
in {
  config = mkIf cfg.enable {
    home.file.".config/swaync/style.css" = {
      source = ../assets/css/notifications.css;
    };
    home.file.".config/swaync/config.json" = {
      source = ../assets/config/notifications.json;
    };
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

          modules-left = ["custom/power" "hyprland/workspaces" "hyprland/window"];
          modules-center = ["privacy" "clock" "custom/notification"];
          modules-right = ["network" "custom/wan" "cpu" "memory" "temperature" "disk" "disk#2" "pulseaudio" "tray"];

          "hyprland/workspaces" = {
            on-click = "activate";
            # https:#github.com/Alexays/Waybar/wiki/Module:-Workspaces#persistent-workspaces
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
              "6" = [];
            };
            format = "{icon}";
            format-icons = {
              "1" = "󰹈";
              "2" = "";
              "3" = "";
              "4" = "󰭹";
              "5" = "󰺵";
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
            format = "  {:%a %b %d <b>%H:%M</b>}";
            exec-on-event = "true";
            on-click = "merkuro";
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

          network = {
            interval = 2;
            format = "󰓅 {bandwidthTotalBits}";
            format-disconnected = "󰌙 Disconnected";
            tooltip-format = "󰖟  {ifname} 󰥔  {frequency} 󰅧  {bandwidthUpBits}   {bandwidthDownBits}";
          };

          disk = {
            interval = 15;
            format = "󰋊 {percentage_used}%";
          };

          "disk#2" = {
            interval = 15;
            format = "󱣐 {percentage_used}%";
            path = "/nix/store";
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
              default = ["" "" ""];
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
            exec = let
              wan =
                pkgs.writeShellScriptBin "wan-ip"
                ''
                  wan_ip=$(curl -s https://checkip.amazonaws.com)
                  echo "󰖟 $wan_ip"
                '';
            in
              lib.getExe wan;
            interval = 2;
          };

          "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
              notification = "󱅫";
              none = "󰂚";
              dnd-notification = "󱏧";
              dnd-none = "󱏧";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "sleep 0.1 && swaync-client -t -sw";
          };
          temperature = {
            # "thermal-zone": 2,
            "hwmon-path" = "/sys/class/hwmon/hwmon2/temp1_input";
            format = "󰈸 {temperatureC}°C";
          };

          privacy = {
            iconSize = 10;
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
