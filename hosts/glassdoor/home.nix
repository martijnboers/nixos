{pkgs, ...}: {
  imports = [
    ../../home/default.nix
  ];

  home.packages = with pkgs; [gqrx yubikey-manager yubikey-manager-qt];

  age.identityPaths = ["/home/martijn/.ssh/id_ed25519_age"];

  # Enable profiles
  hosts.desktop.enable = true;
  hosts.kde.enable = true;
  hosts.personal.enable = true;
  hosts.work.enable = true;
}
