# From: https://github.com/NyCodeGHG/dotfiles/blob/5311b9be5654071abe4b4596946040372157494a/hosts/artemis/applications/pgrok.nix#L20
{
  config,
  pkgs,
  lib,
  utils,
  ...
}: let
  cfg = config.hosts.pgrok;
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
      port = 666;
    };
    database = {
      host = "/run/postgresql";
      user = "pgrok";
      port = 5432;
      database = "pgrok";
    };
    identity_provider = {
      type = "oidc";
      display_name = "Keycloak";
      issuer = "https://auth.plebian.nl/";
      client_id = "pgrok";
      client_secret = {_secret = config.age.secrets.pgrok.path;};
      field_mapping = {
        identifier = "lowercase_username";
        display_name = "name";
        email = "email";
      };
    };
  };
in {
  options.hosts.pgrok = with lib; {
    enable = mkEnableOption "pgrok";
    statePath = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        State Directory for pgrok.
      '';
      default = "/var/lib/pgrok";
    };
    user = mkOption {
      type = types.str;
      default = "pgrok";
      description = lib.mdDoc "User to run pgrok";
    };
    group = mkOption {
      type = types.str;
      default = "pgrok";
      description = lib.mdDoc "Group to run pgrok";
    };
  };
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases = [
        "pgrok"
      ];
      ensureUsers = [
        {
          name = "pgrok";
          ensureDBOwnership = true;
        }
      ];
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      home = cfg.statePath;
      group = cfg.group;
      createHome = true;
    };
    users.groups.${cfg.group} = {};

    systemd.targets.pgrok = {
      description = "Common Target for pgrok";
      wantedBy = ["multi-user.target"];
    };

    systemd.services = let
      configPath = "${cfg.statePath}/config.yml";
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
          User = cfg.user;
          Group = cfg.group;
          TimeoutSec = "infinity";
          Restart = "on-failure";
          WorkingDirectory = cfg.statePath;
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
          User = cfg.user;
          Group = cfg.group;
          TimeoutSec = "infinity";
          Restart = "always";
          WorkingDirectory = cfg.statePath;
          ExecStart = "${pkgs.pgrok.server}/bin/pgrokd --config ${configPath}";
        };
      };
    };
  };
}
