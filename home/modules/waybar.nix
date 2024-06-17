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

          modules-left = ["custom/power" "hyprland/workspaces"];
          modules-center = ["clock" "custom/notification"];
          modules-right = ["cpu" "memory" "disk" "pulseaudio" "tray"];

          "hyprland/workspaces" = {
            on-click = "activate";
            # https://github.com/Alexays/Waybar/wiki/Module:-Workspaces#persistent-workspaces
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
            format = "  {}%";
          };

          disk = {
            interval = 15;
            format = "󰋊 {percentage_used}%";
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

          "custom/sepp" = {
            format = "|";
          };
        }
      ];
    };
  };
}
