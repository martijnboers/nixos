{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  hosts.desktop.enable = false;
  hosts.personal.enable = false;
  hosts.work.enable = false;
}
