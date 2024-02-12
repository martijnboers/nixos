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
      # https://www.jetbrains.com/pycharm/nextversion/
      (pkgs.unstable.jetbrains.pycharm-professional.overrideAttrs {
        version = "241.11761.13";
        postPatch = ''
          rm -rf jbr
          ln -s ${jdk.home} jbr
        '';
        src = builtins.fetchurl {
          url = "https://download-cdn.jetbrains.com/python/pycharm-professional-241.11761.13.tar.gz";
          sha256 = "1ivxiqgavyicjdgqfahdwrrw89i8j0i4ldm2mxhibssbmb0jbjiw";
        };
      })
      # https://www.jetbrains.com/webstorm/nextversion/
      (pkgs.unstable.jetbrains.webstorm.overrideAttrs {
        version = "241.11761.28";
        # Patches don't work with new version
        postPatch = ''
          rm -rf jbr
          ln -s ${jdk.home} jbr
        '';
        src = builtins.fetchurl {
          url = "https://download-cdn.jetbrains.com/webstorm/WebStorm-241.11761.28.tar.gz";
          sha256 = "1v664qdgcw4bbwh95frd07wg3vz5xjjp3nwphky4gn7s8z4kqnc4";
        };
      })
      sublime-merge
      awscli2
      slack
      mongodb-compass
      nodejs_18 # global for work, move to project
      python311Full # move to projects
      httpie-desktop
    ];
  };
}
