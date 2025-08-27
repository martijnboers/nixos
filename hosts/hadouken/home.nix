{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  stylix.enable = false;

  home.packages = with pkgs; [
    zfs
    veracrypt
  ];
}
