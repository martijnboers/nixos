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
    # Setup tailscale default on all machines
    services.tailscale = {
      enable = true;
      openFirewall = true;
      extraUpFlags = [ "--login-server=https://headscale.plebian.nl" ];
    };
    networking.firewall = {
      # Required for tailscale
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
    };
  };
}
