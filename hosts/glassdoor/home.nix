{pkgs, ...}: {
  imports = [
    ../../home/default.nix
  ];

  home.packages = with pkgs; [gqrx yubikey-manager];

  # Enable profiles
  hosts.desktop.enable = true;

  hosts.personal.enable = true;
  hosts.work.enable = true;
}
