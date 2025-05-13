{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.tor;
in
{
  options.hosts.tor = {
    enable = mkEnableOption "Tor relay";
  };

  config = mkIf cfg.enable {
    services.tor = {
      enable = true;
      openFirewall = true;
      relay = {
        enable = true;
        role = "relay";
      };
      settings = {
        ContactInfo = "abuse@plebian.nl";
        Nickname = "personalcloud";
        ORPort = 9002; # NAT forward
        ControlPort = 9051;
        BandWidthRate = "200 MBytes";
        BridgeRelay = true;
        SandBox = true;
        HashedControlPassword = "16:3A7E8EB774B5BD84603C154FCE13C065EF8B0CA0F68E20896720A24B6D";
      };
    };
  };
}
