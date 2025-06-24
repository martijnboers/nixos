{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  # Enable profiles
  maatwerk.desktop.enable = false;

  home.packages = with pkgs; [ zfs ];
}
