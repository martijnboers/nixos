{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    stable.sdrpp # sdr
    electrum-custom
  ];

  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519_age" ];

  programs.git = {
    settings.core.sshCommand = "ssh -i ~/.ssh/id_ed25519_age";
    signing.signByDefault = true;
  };

  # Enable profiles
  maatwerk.hyprland.enable = true;
}
