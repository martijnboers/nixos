{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.maatwerk.kde;
in {
  imports = [./desktop.nix];

  options.maatwerk.kde = {
    enable = mkEnableOption "KDE home manager config";
  };

  config = mkIf cfg.enable {
    maatwerk.desktop.enable = true;

    home.packages = with pkgs; [
      libsForQt5.kdeconnect-kde
      libsForQt5.kompare # diff viewer
      libsForQt5.kate
      nordic
      materia-kde-theme
    ];

    programs.plasma = {
      enable = true;

      spectacle.shortcuts = {
        captureRectangularRegion = "Print";
      };

      panels = [
        {
          location = "top";
          height = 41;
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config.General.icon = "nix-snowflake-white";
            }
            "org.kde.plasma.pager"
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General.launchers = [
                  "applications:librewolf.desktop"
                  "applications:kitty.desktop"
                  "applications:org.kde.dolphin.desktop"
                  "applications:pycharm-community.desktop"
                  "applications:webstorm.desktop"
                  "applications:obsidian.desktop"
                  "applications:sublime_merge.desktop"
                ];
              };
            }
            "org.kde.plasma.marignsseperator"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.systemmonitor.memory"
            {
              name = "org.kde.plasma.systemmonitor.cpucore";
              config.Appearance.chartFace = "org.kde.ksysguard.linechart";
              config.Appearance.title = "cpu does zoom";
            }
            "org.kde.plasma.systemtray"
          ];
        }
      ];

      configFile = {
        "kwinrc"."Desktops"."Number" = {
          value = 3;
          immutable = true;
        };
        "kwinrc"."Desktops"."Rows" = {
          value = 3;
          immutable = true;
        };
      };
    };
  };
}
