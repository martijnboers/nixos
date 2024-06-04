{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  thuis.hyprland.enable = true;
  thuis.personal.enable = false;
  thuis.work.enable = false;
}
