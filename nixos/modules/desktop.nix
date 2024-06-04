{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.desktop;
in {
  options.hosts.desktop = {
    enable = mkEnableOption "Base desktop";
    wayland = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      TERM = "xterm-kitty";
      BROWSER = "firefox";
    };

    # Enable opengpl
    hardware = {
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [rocm-opencl-icd rocm-opencl-runtime];
      };
    };

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager = {
      # Enable automatic login for the user.
      autoLogin.enable = true;
      autoLogin.user = "martijn";
    };

    # Access QMK without sudo
    hardware.keyboard.qmk.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Make it possible to detect printers
    services.avahi = {
      enable = true;
      openFirewall = true;
    };

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}