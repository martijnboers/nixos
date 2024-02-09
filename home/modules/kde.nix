{...}: {
  programs.plasma = {
    enable = true;

    spectacle.shortcuts = {
      captureRectangularRegion = "Print";
    };

    workspace = {
      clickItemTo = "select";
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
                "applications:jetbrains-pycharm-c3d6649e-efde-4daf-954d-c6485d9578f0.desktop"
                "applications:jetbrains-webstorm-76a40067-8d76-4ed7-ad08-5687e250367f.desktop"
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
      "kwinrc"."Desktops"."Number" = 3;
      "kwinrc"."Desktops"."Rows" = 3;
      spectaclerc.General = {
        autoSaveImage = false;
      };
    };
  };
}
