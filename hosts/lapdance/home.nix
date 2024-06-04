{...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  thuis.kde.enable = true;
  thuis.personal.enable = false;
  thuis.work.enable = true;
}
