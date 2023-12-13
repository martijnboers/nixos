{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.ranger;
  functions = {
    r = {
      body = ''
        set NUM (pstree -s %self | grep -o ranger | wc -l)
        if test $NUM -eq 0
          ranger && history --merge
        else
          exit
        end
      '';
    };
  };
in {
  meta.maintainers = [];

  options.programs.ranger = {
    enable = mkEnableOption "ranger, a vim-inspired filemanager for the console";
    enableFishIntegration = mkEnableOption "enable r command in fish";
    package = mkPackageOption pkgs "ranger" {};
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/ranger/rc.conf</filename>. Look at
        <link xlink:href="https://github.com/ranger/ranger/blob/master/ranger/config/rc.conf" />
        for explanation about possible values.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    programs.fish.functions = mkIf cfg.enableFishIntegration functions;
    xdg.configFile."ranger/rc.conf" = mkIf (cfg.extraConfig != "") {text = cfg.extraConfig;};
  };
}
