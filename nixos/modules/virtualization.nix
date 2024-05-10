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
    networkInterface = mkOption {
      type = types.str;
      description = "interface of host";
    };
  };

  config = mkIf cfg.enable {
    # Docker configuration
    virtualisation.docker.enable = true;
    users.users.martijn.extraGroups = ["docker" "libvirtd" "libvirt"];
    environment.systemPackages = with pkgs; [quickemu];

    networking.useNetworkd = true;
    systemd.network.enable = true;

    # Used by microvm
    systemd.network.networks."10-lan" = {
      matchConfig.Name = [cfg.networkInterface "vm-*"];
      networkConfig = {
        Bridge = "br0";
      };
    };
    systemd.network.netdevs."br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };
    systemd.network.networks."10-lan-bridge" = {
      matchConfig.Name = "br0";
      networkConfig = {
        Address = ["192.168.1.2/24" "2001:db8::a/64"];
        Gateway = "192.168.1.1";
        DNS = ["192.168.1.1"];
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
    systemd.network.networks."19-docker" = {
      matchConfig.Name = "veth*";
      linkConfig = {
        Unmanaged = true;
      };
    };

    # QEMU virtualization
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [pkgs.OVMFFull.fd];
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
    programs.virt-manager.enable = true;
  };
}
