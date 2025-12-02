{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    zfs
    stable.veracrypt
  ];
}
