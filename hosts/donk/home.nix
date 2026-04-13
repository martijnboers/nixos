{ ... }:
{
  imports = [
    ../../home
  ];

  wayland.windowManager.hyprland.settings.input.kb_options = "caps:escape";

  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile /home/martijn/.ssh/my-nixbuild-key
  '';

  home.packages = [ ];
  maatwerk.hyprland = {
    enable = true;
    isLaptop = true;
    laptopMonitorName = "eDP-1";
    laptopScalingFactor = 1.0;
  };
}
