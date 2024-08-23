{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.virtualization;
in {
  options.hosts.virtualization = {
    enable = mkEnableOption "Enable virtualization";
  };

  config = mkIf cfg.enable {
    # Docker configuration
    virtualisation.docker.enable = true;
    users.users.martijn.extraGroups = ["docker" "libvirtd" "libvirt"];
    users.extraGroups.vboxusers.members = ["martijn"];

    environment.systemPackages = with pkgs; [quickemu];

    # QEMU virtualization
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [pkgs.OVMFFull.fd];
        };
        onShutdown = "shutdown";
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
    programs.virt-manager.enable = true;
  };
}
