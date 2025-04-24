{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.virtualisation;
in
{
  options.hosts.virtualisation = {
    enable = mkEnableOption "Enable virtualisation for desktop usage";
    qemu = mkOption {
      type = types.bool;
      default = false;
      description = "enable qemu crap";
    };
  };

  config = mkIf cfg.enable {
    # Docker configuration
    virtualisation.docker.enable = true;
    users.users.martijn.extraGroups = [
      "docker"
      "libvirtd"
      "libvirt"
      "kvm"
    ];

    # QEMU configuration, conditionally enabled
    environment.systemPackages = mkIf cfg.qemu (
      with pkgs;
      [
        quickemu
        virt-manager
      ]
    );

    virtualisation.libvirtd = mkIf cfg.qemu {
      enable = true;
      onShutdown = "shutdown";
      parallelShutdown = 10;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    services.qemuGuest.enable = mkIf cfg.qemu true;
  };
}
