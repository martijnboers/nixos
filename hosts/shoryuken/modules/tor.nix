{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.tor;
in {
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
        ORPort = 9001; # NAT forward
        ControlPort = 9051;
        BandWidthRate = "300 MBytes";
        BridgeRelay = true;
      };
    };
  };
}
