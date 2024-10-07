{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.binarycache;
in {
  options.hosts.binarycache = {
    enable = mkEnableOption "Push unstable and custom package to cache";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."binarycache.thuis".extraConfig = ''
         tls internal
         @internal {
           remote_ip 100.64.0.0/10
         }
         handle @internal {
           reverse_proxy http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}
         }
      respond 403
    '';
    age.secrets.binarycache.file = ../../../secrets/binarycache.age;
    services.nix-serve = {
      enable = true;
      port = 3319;
      secretKeyFile = config.age.secrets.binarycache.path;
    };
  };
}
