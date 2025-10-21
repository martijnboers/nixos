{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.virt;
in
{
  options.hosts.virt = {
    enable = mkEnableOption "Default virtualisation desktop setup";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # https://github.com/89luca89/distrobox/blob/main/docs/compatibility.md#containers-distros
      distrobox
      # https://github.com/quickemu-project/quickemu/wiki/05-Advanced-quickemu-configuration
      quickemu
    ];

    environment.etc."distrobox/distrobox.conf".text = ''
      container_additional_volumes="/nix/store:/nix/store:ro"
    '';

    users.users.martijn.extraGroups = [
      "libvirtd"
      "libvirt"
      "kvm"
    ];

    programs.virt-manager.enable = true;

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
      };
      waydroid.enable = true; # android
      libvirtd.enable = true; # virt-manager
      spiceUSBRedirection.enable = true;
    };

    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true; # copy&paste
  };
}
