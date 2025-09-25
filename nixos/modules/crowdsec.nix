{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.crowdsec;
in
{
  options.hosts.crowdsec = {
    enable = mkEnableOption "Crowdsec services on this host";
  };

  config = mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/commits/master/nixos/modules/services/security/crowdsec.nix
  };
}
