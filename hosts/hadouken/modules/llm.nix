{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.llm;
in
{
  options.hosts.llm = {
    enable = mkEnableOption "Local AI models";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "ollama.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://127.0.0.1:${toString config.services.ollama.port}
        }
        respond 403
      '';
      "llm.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://127.0.0.1:${toString config.services.open-webui.port}
        }
        respond 403
      '';
    };

    services.borgbackup.jobs.default.paths = [ config.services.open-webui.stateDir ];

    services.open-webui = {
      enable = true;
      environmentFile = config.age.secrets.llm.path;
      port = 4782;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        WEBUI_AUTH = "False";
	ENABLE_WEB_SEARCH = "True";
	WEB_SEARCH_ENGINE = "duckduckgo";
	OLLAMA_BASE_URL = "https://ollama.thuis";
      };
    };

    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      port = 11434;
      models = "/mnt/zwembad/games/ollama-models";
    };

    age.secrets = {
      llm.file = ../../../secrets/llm.age;
    };
  };
}
