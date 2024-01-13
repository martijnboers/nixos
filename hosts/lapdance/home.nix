{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  hosts.desktop = {
    enable = true;
  };

  hosts.personal.enable = false;
  hosts.work.enable = true;
}
