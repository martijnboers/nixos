{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./modules/caddy.nix
    ./modules/transmission.nix
  ];

  hosts.caddy.enable = true;
  hosts.transmission.enable = true;

  hosts.borg = {
    enable = true;
    repository = "ssh://iv2maozj@iv2maozj.repo.borgbase.com/./repo";
  };

  networking.hostName = "suydersee";

  hosts.resilio = {
    enable = true;
    name = "suydersee";
    ipaddress = "100.64.0.5";
  };

  # don't autologin
  services.xserver.displayManager.autoLogin.enable = false;

  hosts.openssh.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
}
