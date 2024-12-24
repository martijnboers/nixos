{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.ollama;
in {
  options.hosts.ollama = {
    enable = mkEnableOption "Local AI models";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."ollama.thuis".extraConfig = ''
      tls {
        issuer internal { ca hadouken }
      }
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://127.0.0.1:${toString config.services.ollama.port}
      }
      respond 403
    '';

    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      port = 11434;
      models = "/mnt/zwembad/games/ollama-models";
    };
  };
}
