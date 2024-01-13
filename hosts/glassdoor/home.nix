{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  hosts.desktop.enable = true;

  hosts.personal.enable = true;
  hosts.work.enable = true;
}
