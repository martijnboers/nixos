{...}: {
  # KDE
  programs.plasma = {
    enable = true;

    spectacle.shortcuts = {
      captureRectangularRegion = "Print";
    };

    configFile = {
      spectaclerc.General = {
        autoSaveImage = false;
      };
      kdeglobals = {
        Icons.Theme = "Nordic-darker";
      };
    };

    workspace.clickItemTo = "select";
  };
}
