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
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marignsseperator"
          "org.kde.plasma.panelspacer"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.panelspacer"
          "org.kde.plasma.systemmonitor.memmory"
          "org.kde.plasma.systemmonitor.cpucore"
          "org.kde.plasma.systemtray"
        ];
        iconTasksLaunchers = [
          "firefox.desktop"
          "kitty.desktop"
          "org.kde.dolphin.desktop"
          "pycharm-community.desktop"
          "webstorm.desktop"
          "obsidian.desktop"
          "sublime_merge.desktop"
        ];
        extraSettings = ''
          [Containments][57][Applets][65][Configuration][Appearance]
          chartFace=org.kde.ksysguard.linechart
          title=Individual Core Usage

          [Containments][57][Applets][58][Configuration][General]
          favoritesPortedToKAstats=true
          icon=nix-snowflake-white
          systemFavorites=suspend\\,hibernate\\,reboot\\,shutdown
        '';
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
