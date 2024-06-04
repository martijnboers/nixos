{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  hosts.hyprland.enable = true;

  hosts.personal.enable = false;
  hosts.work.enable = false;
}
