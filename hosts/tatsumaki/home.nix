{ ... }:
{
  imports = [
    ../../home
  ];

  # Enable profiles
  maatwerk.desktop.enable = false;
  maatwerk.personal.enable = false;
  maatwerk.work.enable = false;
  maatwerk.nixvim.enable = false;
}
