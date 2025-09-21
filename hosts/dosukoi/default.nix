{
  lib,
  ...
}:
{
  networking.hostName = "dosukoi";

  imports = [
    ./modules/interfaces.nix
    ./modules/firewall.nix
  ];

  # hosts.borg = {
  #   enable = true;
  #   repository = "ssh://iuyrg38x@iuyrg38x.repo.borgbase.com/./repo";
  # };

  users = {
    users.martijn = {
      hashedPasswordFile = lib.mkForce null;
      initialHashedPassword = "$y$j9T$7.j3R9bso7io8OfCT007I1$66Eh2WK1lfhc/aR9FVA.YpI0NiUz60VHD8LAr2j7LCD";
    };
  };

  nix.settings.trusted-users = [ "martijn" ]; # allows remote push
  hosts.server.enable = true;

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.10.0.0/24"
    ];
  };

  hosts.tailscale.enable = true;
  hosts.prometheus.enable = true;

  age = {
    identityPaths = [ "/home/martijn/.ssh/id_ed25519" ];
  };
}
