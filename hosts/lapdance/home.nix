{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  hosts.desktop = true;
  hosts.personal = false;
  hosts.work = true;
}
