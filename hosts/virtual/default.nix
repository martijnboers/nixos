{ lib, config, ... }:
{
  networking.hostName = "usyk";

  # overwrite normal password settings
  users.users.martijn = {
    password = config.hidden.vm_pass;
    hashedPasswordFile = lib.mkForce null;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  hosts.tailscale.enable = true;
}
