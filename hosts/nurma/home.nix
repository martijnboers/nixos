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
    electrum
    android-tools
  ];

  age.identityPaths = [ "/home/martijn/.ssh/id_ed25519_age" ];

  programs.git =
    let
      keychain-sk = "${inputs.secrets}/keys/nurma-sk.pub";
    in
    {
      settings.core.sshCommand = "ssh -i ~/.ssh/id_ed25519_age";
      signing.key = "key::${lib.fileContents keychain-sk}";
    };

  # Enable profiles
  maatwerk.hyprland.enable = true;
}
