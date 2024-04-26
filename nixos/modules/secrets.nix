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
    identityPaths = mkOption {
      type = types.listOf types.str;
      default = ["/home/martijn/.ssh/id_ed25519"];
      description = "Include these paths";
    };
  };

  config = {
    age = {
      identityPaths = cfg.identityPaths;
      secrets = {
        hosts = {
          file = ../../secrets/hosts.age;
          owner = config.users.users.martijn.name;
        };
        password.file = ../../secrets/password.age;
        smb.file = ../../secrets/smb.age;
        borg.file = ../../secrets/borg.age;
      };
    };

    users.users.martijn.hashedPasswordFile = config.age.secrets.password.path;
  };
}
