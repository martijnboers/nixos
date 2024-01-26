{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.secrets;
in {
  options.hosts.secrets = {
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
        password.file = ../../secrets/password.age;
        smb.file = ../../secrets/smb.age;
        openai.file = ../../secrets/openai.age;
        borg.file = ../../secrets/borg.age;
        transmission.file = ../../secrets/transmission.age;
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
