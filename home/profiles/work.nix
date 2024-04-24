{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.work;
in {
  options.hosts.work = {
    enable = mkEnableOption "Enable packages and configuration specfic to work";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vscode
      jetbrains.pycharm-community
      jetbrains.webstorm
      pgrok
      sublime-merge
      awscli2
      slack
      mongodb-compass
      nodejs_18 # global for work, move to project
      python311Full # move to projects
      go
      httpie-desktop
    ];
  };
}
