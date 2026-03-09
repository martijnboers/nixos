{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    stable.sdrpp # sdr
    # electrum
    android-tools
  ];

  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519_age" ];

  programs.git = {
    settings.core.sshCommand = "ssh -i ~/.ssh/id_ed25519_age";
    signing = {
      key = "C1E3 5670 353B 3516 BAA3 51D2 8BA2 F86B 654C 7078";
      format = "gpg";
    };
  };

  # Enable profiles
  maatwerk.hyprland.enable = true;
}
