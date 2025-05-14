{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.calendar;
  radicaleListenAddress = "0.0.0.0:5232";

  fluidCalendarName = "fluidcalendar";

  fluidCalendarStateDir = "/var/lib/${fluidCalendarName}";
  fluidCalendarListenAddress = "0.0.0.0";
  fluidCalendarPort = 3000;

  fluidCalendarDbUser = fluidCalendarName;
  fluidCalendarDbName = "${fluidCalendarName}_db";
in
{
  options.hosts.calendar = {
    enable = mkEnableOption "WebDAV + CardDAV + web calendar";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."cal.thuis".extraConfig = ''
        tls {
          issuer internal { ca hadouken }
        }
        @internal {
          remote_ip 100.64.0.0/10
        }
        handle @internal {
          reverse_proxy http://${radicaleListenAddress}
        }
      respond 403
    '';

    services.postgresql = {
      enable = true;
      ensureUsers = [ { name = fluidCalendarDbUser; } ];
      ensureDatabases = [ fluidCalendarDbName ];
      ensurePermissions = {
        "${fluidCalendarDbName}.${fluidCalendarDbUser}" = "ALL PRIVILEGES";
      };

      authentication = ''
        # TYPE  DATABASE        USER            ADDRESS METHOD
        local   ${fluidCalendarDbName}    ${fluidCalendarDbUser}            peer
      '';
    };

    users.users.${fluidCalendarName} = {
      isSystemUser = true;
      group = fluidCalendarName;
      home = fluidCalendarStateDir;
      createHome = true;
    };
    users.groups.${fluidCalendarName} = { };

    systemd.services.${fluidCalendarName} = {
      description = "Fluid Calendar Next.js application";
      after = [
        "network.target"
        "postgresql.service"
      ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = fluidCalendarName;
        Group = fluidCalendarName;
        Restart = "on-failure";
        RestartSec = "5s";
        WorkingDirectory = "${fluidCalendarAppPackage}/share/${fluidCalendarAppPackage.pname}";
        Environment = [
          "NODE_ENV=production"
          "HOST=${fluidCalendarListenAddress}"
          "PORT=${toString fluidCalendarPort}"
          "DATABASE_URL=postgresql://${fluidCalendarDbUser}@/${fluidCalendarDbName}?host=/run/postgresql"
        ];
        ExecStart = lib.getExe fluidCalendarAppPackage;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        ReadWritePaths = [ fluidCalendarStateDir ];
      };

      preStart = # bash
        ''
          set -e
          echo "Running Prisma migrations for ${fluidCalendarName}..."
          export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
          export PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
          export PRISMA_INTROSPECTION_ENGINE_BINARY="${pkgs.prisma-engines}/bin/introspection-engine"
          export PRISMA_FMT_BINARY="${pkgs.prisma-engines}/bin/prisma-fmt"
          export PRISMA_OPENSSL_BINARY="${pkgs.openssl.bin}/bin/openssl"
          export DATABASE_URL="postgresql://${fluidCalendarDbUser}@/${fluidCalendarDbName}?host=/run/postgresql"
          ${pkgs.prisma}/bin/prisma migrate deploy --schema=${fluidCalendarAppPackage}/share/${fluidCalendarAppPackage.pname}/prisma/schema.prisma
          echo "Prisma migrations completed for ${fluidCalendarName}."
        '';
    };

    services.borgbackup.jobs.default.paths = [ "/var/lib/radicale/collections/" ];
    age.secrets.radicale = {
      file = ../../../secrets/radicale.age;
      owner = "radicale";
      group = "radicale";
    };
    services.radicale = {
      enable = true;
      settings.server.hosts = [ radicaleListenAddress ];
      settings.auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale.path;
        htpasswd_encryption = "autodetect";
      };
    };
  };
}
