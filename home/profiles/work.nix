{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.thuis.work;
  teamsScript = pkgs.writeShellApplication {
    name = "teams";
    runtimeInputs = [pkgs.librewolf];
    text = ''
      librewolf --new-tab https://teams.microsoft.com/
    '';
  };
  teamsDeskopItem = pkgs.makeDesktopItem {
    name = "teams";
    exec = getExe teamsScript;
    desktopName = "Microsoft Teams";
    genericName = "Buissness Communication";
    comment = "Microsoft Teams as Chromium web app.";
    startupWMClass = "teams";
    terminal = true;
  };
in {
  options.thuis.work = {
    enable = mkEnableOption "Enable packages and configuration specfic to work";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jetbrains.pycharm-community
      jetbrains.webstorm
      jetbrains.goland
      pgrok
      sublime-merge
      awscli2
      slack
      mongodb-compass
      go
      httpie-desktop
      distrobox # run any linux distro

      teamsDeskopItem
      teamsScript
      (citrix_workspace.override {version = "24.8.0.98";})
    ];
  };
}
