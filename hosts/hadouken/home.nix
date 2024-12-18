{pkgs, ...}: {
  imports = [
    ../../home
  ];

  # Enable profiles
  maatwerk.desktop.enable = false;
  maatwerk.personal.enable = false;
  maatwerk.work.enable = false;

  home.packages = with pkgs; [zfs seafile-client];
}
