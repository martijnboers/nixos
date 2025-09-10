{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.tailscale;
in
{
  options.hosts.tailscale = {
    enable = mkEnableOption "Enable Tailscale agent";
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      package = pkgs.stable.tailscale;
      openFirewall = true;
      useRoutingFeatures = lib.mkDefault "client";
      disableTaildrop = true;
    };
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
