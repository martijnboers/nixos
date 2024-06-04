{pkgs, ...}: {
  imports = [
    ../../home/default.nix
  ];

  home.packages = with pkgs; [gqrx yubikey-manager yubikey-manager-qt];

  age.identityPaths = ["/home/martijn/.ssh/id_ed25519_age"];

  # Enable profiles
  thuis.kde.enable = true;
  thuis.personal.enable = true;
  thuis.work.enable = true;
}
