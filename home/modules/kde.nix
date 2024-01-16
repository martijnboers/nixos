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
      }
    ];

    configFile = {
      spectaclerc.General = {
        autoSaveImage = false;
      };
    };
  };
}
