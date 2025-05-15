{
  config,
  lib,
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
      openFirewall = true;
      useRoutingFeatures = lib.mkDefault "client";
      port = 0; # autoselect
      disableTaildrop = true;
    };
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
