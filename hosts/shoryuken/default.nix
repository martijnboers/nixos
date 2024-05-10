{...}: {
  networking.hostName = "shoryuken";
  microvm = {
    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 256;
      }
    ];
    interfaces = [
      {
        type = "tap";
        id = "vm-shoryuken";
        mac = "02:00:00:00:00:01";
      }
    ];
    shares = [
      {
        # use "virtiofs" for MicroVMs that are started by systemd
        proto = "9p";
        tag = "ro-store";
        # a host's /nix/store will be picked up so that no
        # squashfs/erofs will be built for it.
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];
    hypervisor = "qemu";
    socket = "control.socket";
  };
  systemd.network.enable = true;
  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      Address = ["192.168.1.3/24" "2001:db8::b/64"];
      Gateway = "192.168.1.1";
      DNS = ["192.168.1.1"];
      IPv6AcceptRA = true;
      DHCP = "no";
    };
  };
}
