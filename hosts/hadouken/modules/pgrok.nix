# From: https://github.com/NyCodeGHG/dotfiles/blob/5311b9be5654071abe4b4596946040372157494a/hosts/artemis/applications/pgrok.nix#L20
{
  config,
  pkgs,
  lib,
  utils,
  ...
}: let
  cfg = config.services.pgrok;
  statePath = "/var/lib/pgrok";

  settings = {
    external_url = "https://tunnel.plebian.nl";
    web = {
      port = 3320;
    };
    proxy = {
      port = 3070;
      scheme = "http";
      domain = "tunnel.plebian.nl";
    };
    sshd = {
      port = 2222;
    };
    database = {
      host = "/run/postgresql";
      user = "pgrok";
      port = 5432;
      database = "pgrok";
    };
    identity_provider = {
      type = "oidc";
      display_name = "Authentik";
      issuer = "https://sso.nycode.dev/application/o/pgrok/";
      client_id = "wkG4JDxfWoK2QpJfYLadmuvWOJn8IEadLxQmaHOc";
      client_secret = {_secret = config.age.secrets.pgrok.path;};
      field_mapping = {
        identifier = "lowercase_username";
        display_name = "name";
        email = "email";
      };
    };
  };
in {
  options.services.pgrok = with lib; {
    enable = mkEnableOption "pgrok";
  };
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases = [
        "pgrok"
      ];
    };

    services.caddy.virtualHosts."tunnel.plebian.nl".extraConfig = ''
      reverse_proxy http://localhost:3320
    '';
    services.caddy.virtualHosts."*.tunnel.plebian.nl".extraConfig = ''
      reverse_proxy http://localhost:3070
    '';

    networking.firewall.allowedTCPPorts = [2222];

    systemd.targets.pgrok = {
      description = "Common Target for pgrok";
      wantedBy = ["multi-user.target"];
    };

    systemd.services = let
      configPath = "${statePath}/config.yml";
    in {
      pgrok-config = {
        wantedBy = ["pgrok.target"];
        partOf = ["pgrok.target"];
        path = with pkgs; [
          jq
          replace-secret
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          TimeoutSec = "infinity";
          Restart = "on-failure";
          WorkingDirectory = statePath;
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "pgrok-config" ''
            umask u=rwx,g=,o=
            ${
              utils.genJqSecretsReplacementSnippet
              settings
              configPath
            }
          '';
        };
      };
      pgrok = {
        after = [
          "network.target"
          "pgrok-config.service"
        ];
        bindsTo = [
          "pgrok-config.service"
        ];
        wantedBy = ["pgrok.target"];
        partOf = ["pgrok.target"];
        serviceConfig = {
          Type = "simple";
          User = "root";
          TimeoutSec = "infinity";
          Restart = "always";
          WorkingDirectory = statePath;
          ExecStart = "${pkgs.pgrok.server}/bin/pgrokd --config ${configPath}";
        };
      };
    };
  };
}
