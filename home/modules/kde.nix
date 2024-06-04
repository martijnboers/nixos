{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.thuis.kde;
in {
  imports = [./desktop.nix];

  options.thuis.kde = {
    enable = mkEnableOption "KDE home manager config";
  };

  config = mkIf cfg.enable {
    thuis.desktop.enable = true;
    programs.plasma = {
      enable = true;

      spectacle.shortcuts = {
        captureRectangularRegion = "Print";
      };

      workspace = {
        theme = "Materia-Color";
        iconTheme = "Nordic-darker";
        wallpaper = ../assets/wallpaper2.jpg;
        colorScheme = "MateriaDark";
        lookAndFeel = "com.github.varlesh.materia-dark";
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
                  "applications:firefox.desktop"
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
