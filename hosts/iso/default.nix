{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "blank";

  # Enable tailscale network
  hosts.tailscale.enable = true;

  # For iso requires password not served by agenix (no ssh keys yet)
  # mkpasswd -m sha-512
  users.users.martijn.hashedPassword = "$6$sD1RYEKq3B4aaQ/n$meCKmgMOxppAsLs4IwdTUmWGUX4WBtm8rMp3Xz8oqpMh54aaP1YSHwFTRHKe/JAkJZMey0eriZhR5PAb1znaM/";
}
