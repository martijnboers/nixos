{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.radicle;
  customExplorer = pkgs.radicle-explorer.withConfig {
    preferredSeeds = [
      {
        hostname = "seed.boers.email";
        port = 443;
        scheme = "https";
      }
    ];
  };
in
{
  options.hosts.radicle = {
    enable = mkEnableOption "Radicle git node";
  };

  config = mkIf cfg.enable {
    age.secrets.radicle-server.file = ../../../secrets/radicle-server.age;

    services.caddy.virtualHosts = {
      "seed.boers.email" = {
        extraConfig = ''
          reverse_proxy ${config.services.radicle.httpd.listenAddress}:${toString config.services.radicle.httpd.listenPort}
        '';
      };
      "git.boers.email" = {
        extraConfig = ''
          root * ${customExplorer}
          file_server
          try_files {path} /index.html
        '';
      };
    };
    services.radicle = {
      enable = true;
      privateKeyFile = config.age.secrets.radicle-server.path;
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpIiSK+rRAp4HPvWrjy2iUluPcInEsHAqJTN5FIOCFc radicle";

      settings = {
        web = {
          avatarUrl = "https://storage.boers.email/random/icon.png";
          bannerUrl = "https://storage.boers.email/random/wallpaper.webp";
          description = "Martijn's Radicle repositories";
          pinned = {
            repositories = [
              "rad:z2Jkf9zxGPxEhCfGLpgRAcHRj8x2n"
              "rad:z3bTedCQLQRkCdAmKKZTMSBimNp4J"
            ];
          };
        };
        node = {
          alias = "shoryuken";
          externalAddresses = [ "seed.boers.email:8776" ];
          seedingPolicy.default = "allow";
        };
      };
      node.openFirewall = true;

      httpd = {
        enable = true;
        listenPort = 8027;
      };
    };
  };
}
