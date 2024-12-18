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
  maatwerk.kitty.enable = true;
  maatwerk.stylix.enable = true;
  maatwerk.desktop.enable = false;
  maatwerk.personal.enable = false;
  maatwerk.work.enable = false;

  home.homeDirectory = lib.mkForce "/Users/martijn";
}
