{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    openssh # mac ssh doesn't support hardware keys
    httpie
    devenv
  ];

  age.identityPaths = [ "/Users/martijn/.ssh/id_ed25519" ];
  home.homeDirectory = lib.mkForce "/Users/martijn";
  stylix.targets.gnome.enable = lib.mkForce false;

  # Enable profiles
  maatwerk.kitty.enable = true;
  maatwerk.stylix.enable = true;
  maatwerk.desktop.enable = false;
}
