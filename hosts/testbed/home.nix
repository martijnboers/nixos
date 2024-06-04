{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  hosts.hyprland.enable = false;
  hosts.personal.enable = false;
  hosts.work.enable = false;
}
