{
  config,
  lib,
  pkgs,
  inputs,
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
    users.users.martijn.extraGroups = ["docker" "libvirtd" "libvirt" "kvm"];
    users.extraGroups.vboxusers.members = ["martijn"];

    # Run seperate windows apps in linux
    environment.systemPackages = with pkgs; [
      quickemu
      virt-manager
      inputs.winapps.packages.${pkgs.system}.winapps
      inputs.winapps.packages.${pkgs.system}.winapps-launcher # optional
    ];

    # QEMU virtualization
    virtualisation = {
      libvirtd = {
        enable = true;
        onShutdown = "shutdown";
        parallelShutdown = 10;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };
    };
    services = {
      qemuGuest.enable = true;
    };
  };
}
