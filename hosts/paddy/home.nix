{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    jetbrains.pycharm-community
    openssh # mac ssh doesn't support hardware keys
    obsidian
    qmk
  ];

  age.identityPaths = ["/Users/martijn/.ssh/id_ed25519"];

  # Enable profiles
  thuis.kitty.enable = true;
  thuis.stylix.enable = true;
  thuis.desktop.enable = false;
  thuis.personal.enable = false;
  thuis.work.enable = false;

  home.homeDirectory = lib.mkForce "/Users/martijn";
}
