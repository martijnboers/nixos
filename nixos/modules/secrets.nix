{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.secrets;
in {
  options.services.secrets = {
    hosts = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    age = {
      identityPaths = [
        "/home/martijn/.ssh/id_ed25519"
      ];
      secrets = {
        hosts = {
          file = ../../secrets/hosts.age;
          owner = config.users.users.martijn.name;
        };
        password = {
          file = ../../secrets/password.age;
          owner = config.users.users.martijn.name;
        };
        smb = {
          file = ../../secrets/smb.age;
          owner = config.users.users.martijn.name;
        };
      };
    };

    users.users.martijn.hashedPasswordFile = config.age.secrets.password.path;

    # readFile copies the content into nix-store but only way
    # to make this work with networking
    networking.extraHosts =
      if cfg.hosts
      then builtins.readFile config.age.secrets.hosts.path
      else "";
  };
}
