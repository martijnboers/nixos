{pkgs, ...}: {
  imports = [
    ../../home/default.nix
  ];

  # Enable profiles
  thuis.desktop.enable = false;
  thuis.personal.enable = false;
  thuis.work.enable = false;

  home.packages = with pkgs; [ollama zfs];
}
