{
  pkgs,
  ...
}:
{
  imports = [
    ../../home
  ];

  # storage constraints
  maatwerk.nixvim.enable = false;
}
