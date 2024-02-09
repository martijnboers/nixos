{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.hosts.work;
in {
  options.hosts.work = {
    enable = mkEnableOption "Enable packages and configuration specfic to work";
  };

  config = mkIf cfg.enable {
    # Install java for jetbrains
    programs.java = {
      enable = true;
      package = pkgs.jetbrains.jdk;
    };

    home.packages = with pkgs; [
      jetbrains-toolbox
      sublime-merge
      awscli2
      slack
      mongodb-compass
      nodejs_18 # global for work, move to project
      python311Full # move to projects
      bundler # ruby stuff
      httpie-desktop
    ];
  };
}
