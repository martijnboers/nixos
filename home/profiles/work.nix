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
      # https://www.jetbrains.com/webstorm/nextversion/
      (pkgs.unstable.jetbrains.webstorm.overrideAttrs {
        version = "241.11761.28";
        # Patches don't work with new version
        postPatch = ''
          rm -rf jbr
          ln -s ${jdk.home} jbr
        '';
        src = builtins.fetchurl {
          url = "https://download-cdn.jetbrains.com/webstorm/WebStorm-241.14494.25.tar.gz";
          sha256 = "04rpag23w55mxm98q8gggdc5n1ax2h4qy7ks7rc7825r3cail94q";
        };
      })
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
