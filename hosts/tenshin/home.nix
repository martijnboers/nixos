{
  pkgs,
  ...
}:
{
  imports = [
    ../../home
  ];

  # Enable profiles
  maatwerk.desktop.enable = false;
  maatwerk.nixvim.enable = false;
}
