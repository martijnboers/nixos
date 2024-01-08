{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.joplin;
  joplin-data = "/srv/joplin/data";
  joplin-uid = "1001";
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
          "${joplin-data}:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environment = {
          APP_BASE_URL = "https://joplin.plebian.nl";
          STORAGE_DRIVER = "Type=Filesystem; Path=/data";
          SQLITE_DATABASE = "/data/db.sqlite";
        };
      };
    };
    systemd.tmpfiles.rules = [
      "d ${joplin-data} 0755 ${joplin-uid} ${joplin-uid} -"
    ];
  };
}
