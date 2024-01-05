{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.ranger;
in {
  options.programs.ranger = {
    enable = mkEnableOption "ranger, a vim-inspired filemanager for the console";
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
    xdg.configFile."ranger/rc.conf" = mkIf (cfg.extraConfig != "") {text = cfg.extraConfig;};
  };
}
