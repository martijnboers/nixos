{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.qemu;
in
{
  options.hosts.qemu = {
    enable = mkEnableOption "QEMU+quickemu";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # https://github.com/quickemu-project/quickemu/wiki/05-Advanced-quickemu-configuration
      quickemu
    ];

    users.users.martijn.extraGroups = [
      "libvirtd"
      "libvirt"
      "kvm"
    ];

    programs.virt-manager.enable = true;

    virtualisation = {
      waydroid.enable = true; # android
      libvirtd.enable = true; # virt-manager
      spiceUSBRedirection.enable = true;
    };

    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true; # copy&paste
  };
}
