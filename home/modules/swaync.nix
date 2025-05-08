{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.maatwerk.hyprland;
in
{
  config = mkIf cfg.enable {
  services.swaync = {
    enable = true;
    settings = {
      "control-center-height" = 2;
      "control-center-layer" = "overlay";
      "control-center-margin-bottom" = 20;
      "control-center-margin-left" = 0;
      "control-center-margin-right" = 10;
      "control-center-margin-top" = 20;
      "control-center-width" = 500;
      "cssPriority" = "application";
      "control-center-positionX" = "right";
      "control-center-positionY" = "center";
      "fit-to-screen" = true;
      "hide-on-action" = false;
      "hide-on-clear" = true;
      "image-visibility" = "when-available";
      "keyboard-shortcuts" = true;
      "layer" = "layer";
      "notification-body-image-height" = 100;
      "notification-body-image-width" = 200;
      "notification-icon-size" = 40;
      "notification-inline-replies" = true;
      "notification-visibility" = { };
      "notification-window-width" = 400;
      "positionX" = "right";
      "positionY" = "top";
      "script-fail-notify" = true;
      "scripts" = { };
      "timeout" = 10;
      "timeout-critical" = 0;
      "timeout-low" = 5;
      "transition-time" = 100;
      "widget-config" = {
        "mpris" = {
          "image-radius" = 12;
          "image-size" = 96;
        };
        "title" = {
          "text" = "Notifications";
          "button-text" = "󰎟 Clear";
          "clear-all-button" = true;
        };
      };

      "widgets" = [
        "title"
        "notifications"
      ];
    };
    style = ../assets/css/notifications.css;
  };
  };
}
