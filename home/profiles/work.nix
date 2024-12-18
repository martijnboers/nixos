{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.maatwerk.work;
  teamsScript = pkgs.writeShellApplication {
    name = "teams";
    runtimeInputs = [pkgs.ungoogled-chromium];
    text = ''
      chromium --new-tab https://teams.microsoft.com/
    '';
  };
  teamsDesktopItem = pkgs.makeDesktopItem {
    name = "teams";
    exec = getExe teamsScript;
    desktopName = "Microsoft Teams";
    genericName = "Business Communication";
    comment = "Microsoft Teams as Chromium web app.";
    startupWMClass = "teams";
    terminal = true;
  };
in {
  options.maatwerk.work = {
    enable = mkEnableOption "Enable packages and configuration specific to work";
  };

  config = mkIf cfg.enable {
    maatwerk.vscode.enable = true;
    home.packages = with pkgs; [
      jetbrains.pycharm-community
      jetbrains.webstorm
      pgrok
      sublime-merge
      awscli2
      slack
      mongodb-compass
      httpie-desktop
      distrobox # run any linux distro

      teamsDesktopItem
      teamsScript
      (citrix_workspace.override {version = "24.8.0.98";})
    ];
  };
}
