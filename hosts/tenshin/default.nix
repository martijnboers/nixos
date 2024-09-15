{...}: {
  networking.hostName = "tenshin";

  hosts.openssh = {
    enable = true;
    allowUsers = ["*@100.64.0.0/10" "*@10.10.0.0/24" "*@10.10.0.0/24"];
  };

  # Enable tailscale network
  hosts.tailscale.enable = true;

  # https://discourse.nixos.org/t/error-gdbus-error-org-freedesktop-dbus-error-serviceunknown-the-name-ca-desrt-dconf-was-not-provided-by-any-service-files/29111
  programs.dconf.enable = true;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
}
