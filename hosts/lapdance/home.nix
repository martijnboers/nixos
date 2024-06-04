{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  hosts.kde.enable = true;
  hosts.personal.enable = false;
  hosts.work.enable = true;
}
