{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.immich;
  images = {
    serverAndMicroservices = {
      imageName = "ghcr.io/immich-app/immich-server";
      imageDigest = "sha256:293673607cdc62be83d4982db491544959070982bdd7bab3181f8bbed485e619"; # v1.91.0
      sha256 = "sha256-lbgZ82TJzNnsjx2VHaN/KEOUK55wKeTjA0bkubnaUt8=";
    };
    machineLearning = {
      imageName = "ghcr.io/immich-app/immich-machine-learning";
      imageDigest = "sha256:4d5614c2f372acdc779a398f9c27e10ae35f3777fd34dd3f63cf88012644438f"; # v1.91.0
      sha256 = "sha256-df00J92Uils7uaoqMkxt97ALgWIjXwY+fxku0OvIiHY=";
    };
  };
  dbUsername = user;
  redisName = "immich";

  photosLocation = "/mnt/garage/Immich";

  user = "immich";
  group = user;
  uid = 15015;
  gid = 15015;

  immichWebUrl = "http://immich_web:3000";
  immichServerUrl = "http://immich_server:3001";
  immichMachineLearningUrl = "http://immich_machine_learning:3003";

  domain = "photos.plebian.nl"; # todo put on tailscale
  immichExternalPort = 8084;

  environment = {
    DB_URL = "socket://${dbUsername}:@/run/postgresql?db=${dbUsername}";
    REDIS_SOCKET = config.services.redis.servers.${redisName}.unixSocket;
    UPLOAD_LOCATION = photosLocation;
    IMMICH_WEB_URL = immichWebUrl;
    IMMICH_SERVER_URL = immichServerUrl;
    IMMICH_MACHINE_LEARNING_URL = immichMachineLearningUrl;
  };

  wrapImage = {
    name,
    imageName,
    imageDigest,
    sha256,
    entrypoint,
  }:
    pkgs.dockerTools.buildImage {
      name = name;
      tag = "release";
      fromImage = pkgs.dockerTools.pullImage {
        imageName = imageName;
        imageDigest = imageDigest;
        sha256 = sha256;
      };
      created = "now";
      config =
        if builtins.length entrypoint == 0
        then null
        else {
          Cmd = entrypoint;
          WorkingDir = "/usr/src/app";
        };
    };
  mkMount = dir: "${dir}:${dir}";
in {
  options.hosts.immich = {
    enable = mkEnableOption "Google Photos replacement";
  };

  config = mkIf cfg.enable {
    users.users.${user} = {
      inherit group uid;
      isSystemUser = true;
    };
    users.groups.${group} = {inherit gid;};

    services.postgresql = {
      ensureUsers = [
        {
          name = dbUsername;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [dbUsername];

      extraPlugins = [
        (pkgs.pgvecto-rs.override rec {
          postgresql = config.services.postgresql.package;
          stdenv = postgresql.stdenv;
        })
      ];
      settings = {shared_preload_libraries = "vectors.so";};
    };

    services.redis.servers.${redisName} = {
      inherit user;
      enable = true;
    };

    systemd.tmpfiles.rules = ["d ${photosLocation} 0750 ${user} ${group}"];

    virtualisation.oci-containers.containers = {
      immich_server = {
        imageFile = wrapImage {
          inherit (images.serverAndMicroservices) imageName imageDigest sha256;
          name = "immich_server";
          entrypoint = ["/bin/sh" "start-server.sh"];
        };
        image = "immich_server:release";
        extraOptions = ["--network=immich-bridge" "--user=${toString uid}:${toString gid}"];

        volumes = [
          "${photosLocation}:/usr/src/app/upload"
          (mkMount "/run/postgresql")
          (mkMount "/run/redis-${redisName}")
        ];

        environment =
          environment
          // {
            PUID = toString uid;
            PGID = toString gid;
          };

        ports = ["${toString immichExternalPort}:3001"];

        autoStart = true;
      };

      immich_microservices = {
        imageFile = wrapImage {
          inherit (images.serverAndMicroservices) imageName imageDigest sha256;
          name = "immich_microservices";
          entrypoint = ["/bin/sh" "start-microservices.sh"];
        };
        image = "immich_microservices:release";
        extraOptions = ["--network=immich-bridge" "--user=${toString uid}:${toString gid}"];

        volumes = [
          "${photosLocation}:/usr/src/app/upload"
          (mkMount "/run/postgresql")
          (mkMount "/run/redis-${redisName}")
        ];

        environment =
          environment
          // {
            PUID = toString uid;
            PGID = toString gid;
            REVERSE_GEOCODING_DUMP_DIRECTORY = "/tmp/reverse-geocoding-dump";
          };

        autoStart = true;
      };

      immich_machine_learning = {
        imageFile = pkgs.dockerTools.pullImage images.machineLearning;
        image = "ghcr.io/immich-app/immich-machine-learning";
        extraOptions = ["--network=immich-bridge"];

        environment = environment;

        volumes = ["immich-model-cache:/cache"];

        autoStart = true;
      };
    };

    systemd.services.init-immich-network = {
      description = "Create the network bridge for immich.";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "oneshot";
      script = ''
        # Put a true at the end to prevent getting non-zero return code, which will
        # crash the whole service.
        check=$(${pkgs.docker}/bin/docker network ls | grep "immich-bridge" || true)
        if [ -z "$check" ];
          then ${pkgs.docker}/bin/docker network create immich-bridge
          else echo "immich-bridge already exists in docker"
        fi
      '';
    };

    services.caddy.virtualHosts.domain.extraConfig = ''
      reverse_proxy localhost:${toString immichExternalPort}
    '';

    # https://immich.app/docs/administration/backup-and-restore
    services.borgbackup.jobs.home-hadouken.paths = [
      "${photosLocation}/library"
      "${photosLocation}/upload"
      "${photosLocation}/profile"
    ];
  };
}
