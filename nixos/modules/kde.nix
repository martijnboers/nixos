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
    enable = mkEnableOption "Support KDE desktop";
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
    services.xserver.displayManager = {
      # Auto loging crash
      # sddm.enable = true;
      lightdm.enable = true;

      # Enable automatic login for the user.
      autoLogin.enable = true;
      autoLogin.user = "martijn";

      defaultSession =
        if cfg.wayland
        then "plasmawayland"
        else "plasma";
    };

    services.xserver.desktopManager.plasma5.enable = true;

    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
      elisa
      khelpcenter
      konsole
    ];

    # Access QMK without sudo
    hardware.keyboard.qmk.enable = true;

    # Configure keymap in X11
    services.xserver = {
      layout = "us";
      xkbVariant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    sound.enable = true;
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
