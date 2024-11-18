{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.search;
in {
  options.hosts.search = {
    enable = mkEnableOption "SearXNG";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."search.thuis".extraConfig = ''
      tls internal
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.searx.settings.server.port}
      }
      respond 403
    '';

    age.secrets.searxng.file = ../../../secrets/searxng.age;
    users.groups.searx.members = ["caddy"];

    services.searx = {
      enable = true;
      redisCreateLocally = true;
      environmentFile = config.age.secrets.searxng.path;
      package = pkgs.searxng;

      # Searx configuration
      settings = {
        # Instance settings
        general = {
          debug = false;
          instance_name = "don't be evil";
          donation_url = false;
          contact_url = false;
          privacypolicy_url = false;
          enable_metrics = false;
        };

        # User interface
        ui = {
          static_use_hash = true;
          default_locale = "en";
          query_in_title = false;
          infinite_scroll = true;
          center_alignment = true;
          default_theme = "simple";
          theme_args.simple_style = "auto";
          search_on_category_select = false;
          hotkeys = "vim";
        };

        # Search engine settings
        search = {
          safe_search = 0; # 0 = off, 1 = moderate, 2 = strict
          autocomplete_min = 2;
          autocomplete = "google";
          ban_time_on_fail = 5;
          max_ban_time_on_fail = 120;
        };

        # Server configuration
        server = {
          port = 4359;
          bind_address = "0.0.0.0";
          secret_key = "@SEARX_SECRET_KEY@";
          limiter = false;
          public_instance = false;
          image_proxy = true;
        };

        # Enabled plugins
        enabled_plugins = [
          "Open Access DOI rewrite"
          "Basic Calculator"
          "Hostnames plugin"
          "Unit converter plugin"
          "Tracker URL remover"
        ];
      };
    };
  };
}
