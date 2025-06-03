{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.calendar;
  radicaleListenAddress = "0.0.0.0:5232";

  fluidCalendarName = "fluidcalendar";
  fluidCalendarUser = fluidCalendarName;
  fluidCalendarDbName = fluidCalendarName;
  fluidCalendarSocketDir = "/run/postgresql"; # Standard PostgreSQL socket directory

  fluidCalendarStateDir = "/var/lib/${fluidCalendarName}";
  fluidCalendarListenAddress = "127.0.0.1";
  fluidCalendarPort = 3000;
  fluidCalendarAppPackage = pkgs.fluid-calendar;
  fluidCalendarAppDir = "${fluidCalendarAppPackage}/share/${fluidCalendarAppPackage.pname}";
  fluidCalendarDomain = "https://kal.thuis";

  databaseUrl = "postgresql://${fluidCalendarUser}@localhost/${fluidCalendarDbName}?host=${fluidCalendarSocketDir}";

in
{
  options.hosts.calendar = {
    enable = mkEnableOption "WebDAV + CardDAV + web calendar";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "kal.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://${fluidCalendarListenAddress}:${toString fluidCalendarPort}
        }
        respond 403
      '';
      "cal.thuis".extraConfig = ''
        import headscale
        handle @internal {
          reverse_proxy http://${radicaleListenAddress}
        }
        respond 403
      '';
    };

    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = fluidCalendarUser;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ fluidCalendarDbName ];
    };

    users.users.${fluidCalendarUser} = {
      isSystemUser = true;
      group = fluidCalendarUser;
      home = fluidCalendarStateDir;
      createHome = true;
    };
    users.groups.${fluidCalendarUser} = { };

    systemd.services.${fluidCalendarName} = {
      description = "Fluid Calendar Next.js application";
      after = [
        "network.target"
        "postgresql.service"
      ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = fluidCalendarUser;
        Group = fluidCalendarUser;
        Restart = "on-failure";
        RestartSec = "5s";
        WorkingDirectory = fluidCalendarAppDir; # For the main ExecStart
        Environment = [
          "NEXTAUTH_URL=${fluidCalendarDomain}"
          "NEXT_PUBLIC_APP_URL=${fluidCalendarDomain}"
          "NEXTAUTH_SECRET=${config.hidden.fluid-calendar.secret-key}"
          "NEXT_PUBLIC_SITE_URL=${fluidCalendarDomain}"

          "HOST=${fluidCalendarListenAddress}"
          "PORT=${toString fluidCalendarPort}"
          "DATABASE_URL=${databaseUrl}"

          "NODE_EXTRA_CA_CERTS=${../../../secrets/keys/hadouken.crt}" # trust connections to tls internal radicale
        ];
        ExecStart = lib.getExe fluidCalendarAppPackage;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        ReadWritePaths = [
          fluidCalendarStateDir
          ../../../secrets/keys
        ];
      };

      # preStart script runs with User and Group from serviceConfig.
      # Environment variables from serviceConfig.Environment are also available.
      preStart = # bash
        ''
          set -euo pipefail # exit on error, undefined variable, pipe failure

          # Set WorkingDirectory for this preStart script
          cd "${fluidCalendarAppDir}"

          # Make postgresql client tools (like pg_isready) available in PATH
          export PATH="${pkgs.postgresql}/bin:$PATH"

          # Wait for PostgreSQL to be ready
          echo "Waiting for PostgreSQL service at ${fluidCalendarSocketDir} to be ready for user ${fluidCalendarUser} on db ${fluidCalendarDbName}..."
          timeout_seconds=30
          start_time=$(date +%s)
          while ! pg_isready -U "${fluidCalendarUser}" -d "${fluidCalendarDbName}" -h "${fluidCalendarSocketDir}" -q; do
            current_time=$(date +%s)
            if [ $((current_time - start_time)) -ge $timeout_seconds ]; then
              echo "Timed out waiting for PostgreSQL."
              # Attempt one last pg_isready without -q to see its error output
              pg_isready -U "${fluidCalendarUser}" -d "${fluidCalendarDbName}" -h "${fluidCalendarSocketDir}"
              exit 1
            fi
            echo "PostgreSQL not yet ready, retrying in 1 second..."
            sleep 1
          done
          echo "PostgreSQL is ready."

          # DATABASE_URL and PRISMA_* variables are inherited from serviceConfig.Environment
          echo "Using DATABASE_URL for migrations: $DATABASE_URL" # Verify it's inherited

          echo "Running Prisma migrations for ${fluidCalendarName}..."
          # Use relative path to schema because we 'cd' into fluidCalendarAppDir
          ${pkgs.prisma}/bin/prisma migrate deploy --schema=prisma/schema.prisma

          echo "Prisma migrations completed for ${fluidCalendarName}."

        '';
    };

    services.borgbackup.jobs.default.paths = [
      "/var/lib/radicale/collections/"
      fluidCalendarStateDir
    ];

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
