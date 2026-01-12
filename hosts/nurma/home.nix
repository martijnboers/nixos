{ pkgs, lib, ... }:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    stable.sdrpp # sdr
    electrum
    android-tools
  ];

  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519_age" ];

  programs.git = {
    settings.core.sshCommand = "ssh -i ~/.ssh/id_ed25519_age";
    signing.key = "key::${lib.fileContents ../../secrets/keys/nurma-sk.pub}";
  };

  # Enable profiles
  maatwerk.hyprland.enable = true;
}
