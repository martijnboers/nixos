{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.server;
in {
  options.hosts.server = {
    enable = mkEnableOption "Server defaults";
  };

  config = mkIf cfg.enable {
    environment = {
      # Print the URL instead on servers
      variables.BROWSER = "echo";
    };

    # No need for fonts on a server
    fonts.fontconfig.enable = lib.mkDefault false;

    # freedesktop xdg files
    xdg.autostart.enable = lib.mkDefault false;
    xdg.icons.enable = lib.mkDefault false;
    xdg.menus.enable = lib.mkDefault false;
    xdg.mime.enable = lib.mkDefault false;
    xdg.sounds.enable = lib.mkDefault false;

    # Delegate the hostname setting to dhcp/cloud-init by default
    networking.hostName = lib.mkOverride 1337 ""; # lower prio than lib.mkDefault

    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    boot.initrd.systemd.suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
      "emergency.service"
      "emergency.target"
    ];
    boot.tmp.cleanOnBoot = lib.mkDefault true;

    systemd = {
      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };

    # Make sure the serial console is visible in qemu when testing the server configuration
    # with nixos-rebuild build-vm
    virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;
  };
}
