{
  config,
  pkgs,
  ...
}: let
  immichHost = "immich.thuis.plebian.nl";

  immichRoot = "/mnt/garage/Pictures";
  immichPhotos = "${immichRoot}/photos";
  immichAppdataRoot = "${immichRoot}/appdata";
  immichVersion = "release";

  postgresRoot = "${immichAppdataRoot}/pgsql";
  postgresUser = "immich";
  postgresDb = "immich";
in {
  services.caddy.virtualHosts."${immichHost}".extraConfig = ''
       tls internal
       @internal {
         remote_ip 100.64.0.0/10
       }
       handle @internal {
         reverse_proxy http://127.0.0.1:2283
       }
    respond 403
  '';

  age.secrets.immich = {
    file = ../../../secrets/immich.age;
    owner = virtualisation.oci-containers.user;
  };

  services.borgbackup.jobs.default.paths = [immichPhotos];

  # The primary source for this configuration is the recommended docker-compose installation of immich from
  # https://immich.app/docs/install/docker-compose, which linkes to:
  # - https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
  # - https://github.com/immich-app/immich/releases/latest/download/example.env
  # and has been transposed into nixos configuration here.  Those upstream files should probably be checked
  # for serious changes if there are any upgrade problems here.
  #
  # After initial deployment, these in-process configurations need to be done:
  # - create an admin user by accessing the site
  # - login with the admin user
  # - set the "Machine Learning Settings" > "URL" to http://immich_machine_learning:3003

  virtualisation.oci-containers.containers.immich_server = {
    image = "ghcr.io/immich-app/immich-server:${immichVersion}";
    ports = ["127.0.0.1:2283:3001"];
    extraOptions = [
      "--pull=newer"
      # Force DNS resolution to only be the podman dnsname name server; by default podman provides a resolv.conf
      # that includes both this server and the upstream system server, causing resolutions of other pod names
      # to be inconsistent.
      "--dns=10.88.0.1"
    ];
    cmd = ["start.sh" "immich"];
    environment = {
      IMMICH_VERSION = immichVersion;
      DB_HOSTNAME = "immich_postgres";
      DB_USERNAME = postgresUser;
      DB_DATABASE_NAME = postgresDb;
      REDIS_HOSTNAME = "immich_redis";
    };
    environmentFiles = [config.age.secrets.immich.path];
    volumes = [
      "${immichPhotos}:/usr/src/app/upload"
      "/etc/localtime:/etc/localtime:ro"
      "${immichExternalVolume1}:${immichExternalVolume1}:ro"
    ];
  };

  virtualisation.oci-containers.containers.immich_microservices = {
    image = "ghcr.io/immich-app/immich-server:${immichVersion}";
    extraOptions = [
      "--pull=newer"
      # Force DNS resolution to only be the podman dnsname name server; by default podman provides a resolv.conf
      # that includes both this server and the upstream system server, causing resolutions of other pod names
      # to be inconsistent.
      "--dns=10.88.0.1"
    ];
    cmd = ["start.sh" "microservices"];
    environment = {
      IMMICH_VERSION = immichVersion;
      DB_HOSTNAME = "immich_postgres";
      DB_USERNAME = postgresUser;
      DB_DATABASE_NAME = postgresDb;
      REDIS_HOSTNAME = "immich_redis";
    };
    environmentFiles = [config.age.secrets.immich.path];
    volumes = [
      "${immichPhotos}:/usr/src/app/upload"
      "/etc/localtime:/etc/localtime:ro"
      "${immichExternalVolume1}:${immichExternalVolume1}:ro"
    ];
  };

  virtualisation.oci-containers.containers.immich_machine_learning = {
    image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}";
    extraOptions = ["--pull=newer"];
    environment = {
      IMMICH_VERSION = immichVersion;
    };
    volumes = [
      "${immichAppdataRoot}/model-cache:/cache"
    ];
  };

  virtualisation.oci-containers.containers.immich_redis = {
    image = "redis:6.2-alpine@sha256:80cc8518800438c684a53ed829c621c94afd1087aaeb59b0d4343ed3e7bcf6c5";
  };

  virtualisation.oci-containers.containers.immich_postgres = {
    image = "tensorchord/pgvecto-rs:pg14-v0.1.11";
    environment = {
      POSTGRES_USER = postgresUser;
      POSTGRES_DB = postgresDb;
    };
    environmentFiles = [config.age.secrets.immich.path];
    volumes = [
      "${postgresRoot}:/var/lib/postgresql/data"
    ];
  };
}
