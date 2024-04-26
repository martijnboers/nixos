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
        password.file = ../../secrets/password.age;
        smb.file = ../../secrets/smb.age;
      };
    };
  };
}
