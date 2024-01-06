{
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "hadouken";

  # Enable ssh for host
  programs.openssh.enable = true;
}
