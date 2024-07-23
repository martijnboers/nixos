{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.ollama;
  models = "/mnt/zwembad/games/ollama-models";
in {
  options.hosts.ollama = {
    enable = mkEnableOption "Local AI models";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."ollama.thuis".extraConfig = ''
      tls internal
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://${toString config.services.ollama.listenAddress}
      }
      respond 403
    '';

    services.ollama = {
      enable = true;
      listenAddress = "0.0.0.0:11434";
      inherit models;
      writablePaths = [models];
    };
  };
}
