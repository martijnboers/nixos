{ ... }:
{
  imports = [
    ../../home
  ];

  home.packages = [ ];
  maatwerk.hyprland = {
    enable = true;
    isLaptop = true;
  };
}
