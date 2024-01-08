{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.joplin;
  joplin-data = "/srv/joplin/data";
  joplin-db-data = "/srv/joplin/postgres";
  joplin-uid = "1001";
  backend = config.virtualisation.oci-containers.backend;
  pod-name = "joplin-pod";
  open-ports = ["127.0.0.1:22300:22300/tcp"];
in {
  options.hosts.joplin = {
    enable = mkEnableOption "Joplin server";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      joplin = {
        image = "docker.io/joplin/server:latest";
        ports = ["127.0.0.1:22300:22300"];
        volumes = [
          "/home/martijn/Data/joplin:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environment = {
          APP_BASE_URL = "https://joplin.plebian.nl";
          STORAGE_DRIVER = "Type=Filesystem; Path=/data";
          SQLITE_DATABASE = "/data/db.sqlite";
        };
      };
    };
  };
}
