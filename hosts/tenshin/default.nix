{...}: {
  networking.hostName = "tenshin";

  imports = [
    ./modules/endlessh.nix
  ];

  hosts.endlessh.enable = true;
  hosts.prometheus.enable = true;

  # SDR
  hardware.rtl-sdr.enable = true;

  hosts.openssh = {
    enable = true;
    allowUsers = ["*@100.64.0.0/10" "*@10.10.0.0/24"];
  };

  # Enable tailscale network
  hosts.tailscale.enable = true;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
}
